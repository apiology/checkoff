# typed: true
# frozen_string_literal: true

require 'forwardable'
require_relative 'projects'
require_relative 'workspaces'
require_relative 'clients'
require_relative 'my_tasks'
require_relative 'internal/logging'

module Checkoff
  # Query different sections of Asana projects
  class Sections
    # @!parse
    #   extend CacheMethod::ClassMethods

    MINUTE = 60
    HOUR = MINUTE * 60
    REALLY_LONG_CACHE_TIME = MINUTE * 30
    LONG_CACHE_TIME = MINUTE * 15
    SHORT_CACHE_TIME = MINUTE * 5

    extend Forwardable

    # @return [Checkoff::Projects]
    attr_reader :projects

    # @return [Checkoff::Workspaces]
    attr_reader :workspaces

    # @return [Class<Time>]
    attr_reader :time

    # @return [Checkoff::MyTasks]
    attr_reader :my_tasks

    # @param config [Checkoff::Internal::EnvFallbackConfigLoader,Hash]
    # @param client [Asana::Client]
    # @param projects [Checkoff::Projects]
    # @param workspaces [Checkoff::Workspaces]
    # @param time [Class<Time>]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   client: Checkoff::Clients.new(config:).client,
                   projects: Checkoff::Projects.new(config:,
                                                    client:),
                   workspaces: Checkoff::Workspaces.new(config:,
                                                        client:),
                   time: Time)
      @projects = projects
      @workspaces = workspaces
      @my_tasks = Checkoff::MyTasks
        .new(config:, projects:, client:)
      @client = client
      @time = time
    end

    # Returns a list of Asana API section objects for a given project
    # @param workspace_name [String]
    # @param project_name [String, Symbol]
    # @param extra_fields [Array<String>]
    #
    # @return [Enumerable<Asana::Resources::Section>]
    def sections_or_raise(workspace_name, project_name, extra_fields: [])
      project = project_or_raise(workspace_name, project_name)
      sections_by_project_gid(project.gid, extra_fields:)
    end
    cache_method :sections_or_raise, SHORT_CACHE_TIME

    # Returns a list of Asana API section objects for a given project GID
    # @param project_gid [String]
    # @param extra_fields [Array<String>]
    #
    # @return [Enumerable<Asana::Resources::Section>]
    def sections_by_project_gid(project_gid, extra_fields: [])
      fields = (%w[name] + extra_fields).sort.uniq
      client.sections.get_sections_for_project(project_gid:,
                                               options: { fields: })
    end
    cache_method :sections_by_project_gid, SHORT_CACHE_TIME

    # Given a workspace name and project name, then provide a Hash of
    # tasks with section name -> task list of the uncompleted tasks
    # @param workspace_name [String]
    # @param project_name [String, Symbol]
    # @param only_uncompleted [Boolean]
    # @param extra_fields [Array<String>]
    # @return [Hash{String, nil => Enumerable<Asana::Resources::Task>}]
    def tasks_by_section(workspace_name,
                         project_name,
                         only_uncompleted: true,
                         extra_fields: [])
      raise ArgumentError, 'Provided nil workspace name' if T.unsafe(workspace_name).nil?
      raise ArgumentError, 'Provided nil project name' if T.unsafe(project_name).nil?

      project = project_or_raise(workspace_name, project_name)
      if project_name == :my_tasks
        my_tasks.tasks_by_section_for_my_tasks(project, only_uncompleted:, extra_fields:)
      else
        tasks_by_section_for_project(project, only_uncompleted:, extra_fields:)
      end
    end

    # @param section_gid [String]
    # @param only_uncompleted [Boolean]
    # @param extra_fields [Array<String>]
    #
    # @return [Enumerable<Asana::Resources::Task>]
    def tasks_by_section_gid(section_gid,
                             only_uncompleted: true,
                             extra_fields: [])
      options = projects.task_options(extra_fields:,
                                      only_uncompleted:)
      client.tasks.get_tasks(section: section_gid, **options)
    end

    # Pulls task objects from a specified section
    #
    # @param workspace_name [String]
    # @param project_name [String, Symbol]
    # @param section_name [String, nil]
    # @param only_uncompleted [Boolean]
    # @param extra_fields [Array<String>]
    #
    # @return [Enumerable<Asana::Resources::Task>]
    def tasks(workspace_name, project_name, section_name,
              only_uncompleted: true,
              extra_fields: [])
      section = section_or_raise(workspace_name, project_name, section_name)
      options = projects.task_options(extra_fields:,
                                      only_uncompleted:)
      # Note: 30 minute cache time on a raw Enumerable from SDK gives
      # 'Your pagination token has expired' errors.  So we go ahead
      # and eagerly evaluate here so we can enjoy the cache.
      client.tasks.get_tasks(section: section.gid,
                             **options).to_a
    end
    cache_method :tasks, REALLY_LONG_CACHE_TIME

    # Pulls just names of tasks from a given section.
    # @param workspace_name [String]
    # @param project_name [String, Symbol]
    # @param section_name [String, nil]
    #
    # @sg-ignore
    # @return [Array<String>]
    def section_task_names(workspace_name, project_name, section_name)
      task_array = tasks(workspace_name, project_name, section_name)
      # @type [Array<String>]
      T.cast(task_array.map(&:name), T::Array[String])
    end
    cache_method :section_task_names, SHORT_CACHE_TIME

    # @param workspace_name [String]
    # @param project_name [String, Symbol]
    # @param section_name [String, nil]
    # @param extra_section_fields [Array<String>]
    #
    # @sg-ignore
    # @return [Asana::Resources::Section]
    def section_or_raise(workspace_name, project_name, section_name, extra_section_fields: [])
      s = section(workspace_name, project_name, section_name,
                  extra_section_fields:)
      if s.nil?
        valid_sections = sections_or_raise(workspace_name, project_name,
                                           extra_fields: extra_section_fields).map(&:name)

        raise "Could not find section #{section_name.inspect} under project #{project_name.inspect} " \
              "under workspace #{workspace_name.inspect}.  Valid sections: #{valid_sections.inspect}"
      end
      s
    end
    cache_method :section_or_raise, LONG_CACHE_TIME

    # @param name [String]
    # @return [String, nil]
    def section_key(name)
      inbox_section_names = ['(no section)', 'Untitled section', 'Inbox', 'Recently assigned']
      return nil if inbox_section_names.include?(name)

      name
    end

    # @param section [Asana::Resources::Section]
    #
    # @return [Asana::Resources::Section, nil]
    def previous_section(section)
      sections = sections_by_project_gid(section.project.fetch('gid'))

      # @type [Array<Asana::Resources::Section>]
      sections = sections.to_a

      index = sections.find_index { |s| s.gid == section.gid }
      return nil if index.nil? || index.zero?

      sections[index - 1]
    end
    cache_method :previous_section, SHORT_CACHE_TIME

    # @param gid [String]
    #
    # @return [Asana::Resources::Section, nil]
    def section_by_gid(gid)
      options = {}
      Asana::Resources::Section.new(parse(client.get("/sections/#{gid}", options:)).first,
                                    client:)
    rescue Asana::Errors::NotFound => e
      debug e
      nil
    end
    cache_method :section_by_gid, SHORT_CACHE_TIME

    # @return [Hash]
    def as_cache_key
      {}
    end

    # @sg-ignore
    # @param workspace_name [String]
    # @param project_name [String, Symbol]
    # @param section_name [String, nil]
    # @param extra_section_fields [Array<String>]
    #
    # @return [Asana::Resources::Section, nil]
    def section(workspace_name, project_name, section_name, extra_section_fields: [])
      sections = sections_or_raise(workspace_name, project_name,
                                   extra_fields: extra_section_fields)
      sections.find { |section| section_key(T.cast(section.name, String))&.chomp(':') == section_name&.chomp(':') }
    end

    private

    include Logging

    # https://github.com/Asana/ruby-asana/blob/master/lib/asana/resource_includes/response_helper.rb#L7
    # @param response [Asana::HttpClient::Response]
    #
    # @return [Array<Hash, Hash>]
    def parse(response)
      data = response.body.fetch('data') do
        raise("Unexpected response body: #{response.body}")
      end
      extra = response.body.except('data')
      [data, extra]
    end

    # @return [Asana::Client]
    attr_reader :client

    # Given a project object, pull all tasks, then provide a Hash of
    # tasks with section name -> task list of the uncompleted tasks
    # @param project [Asana::Resources::Project]
    # @param only_uncompleted [Boolean]
    # @param extra_fields [Array<String>]
    # @return [Hash{String,nil => Enumerable<Asana::Resources::Task>}]
    def tasks_by_section_for_project(project,
                                     only_uncompleted: true,
                                     extra_fields: [])
      raw_tasks = projects.tasks_from_project(project,
                                              only_uncompleted:,
                                              extra_fields:)
      active_tasks = projects.active_tasks(raw_tasks)
      by_section(active_tasks, project.gid)
    end

    # Given a list of tasks, pull a Hash of tasks with section name -> task list
    # @param tasks [Enumerable<Asana::Resources::Task>]
    # @param project_gid [String]
    # @return [Hash{String, nil => Enumerable<Asana::Resources::Task>}]
    def by_section(tasks, project_gid)
      by_section = {}
      # @sg-ignore
      sections = client.sections.get_sections_for_project(project_gid:,
                                                          options: { fields: ['name'] })
      sections.each_entry { |section| by_section[section_key(section.name)] = [] }
      tasks.each { |task| file_task_by_section(by_section, task, project_gid) }
      by_section
    end
    cache_method :by_section, LONG_CACHE_TIME

    # @param by_section [Hash{String, nil => Array<Asana::Resources::Task>}]
    # @param task [Asana::Resources::Task]
    # @param project_gid [String]
    # @return [void]
    def file_task_by_section(by_section, task, project_gid)
      membership = task.memberships.find { |m| T.cast(m['project'], T::Hash[String, T.untyped])['gid'] == project_gid }
      raise "Could not find task in project_gid #{project_gid}: #{task}" if membership.nil?

      section = T.cast(membership['section'], T::Hash[String, T.untyped])
      section_name = T.cast(section['name'], String)

      # @type [String, nil]
      current_section = section_key(section_name)

      # @sg-ignore
      by_section.fetch(current_section) << task
    end

    # @param workspace_name [String]
    # @param project_name [String, Symbol]
    # @return [Asana::Resources::Project]
    def project_or_raise(workspace_name, project_name)
      raise ArgumentError, 'Provide nil project_name' if T.unsafe(project_name).nil?

      project = projects.project(workspace_name, project_name)
      if project.nil?
        raise "Could not find project #{project_name.inspect} " \
              "under workspace #{workspace_name}"
      end
      project
    end
  end
end
