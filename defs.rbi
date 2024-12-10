# typed: strong
# https://developers.asana.com/reference/searchtasksforworkspace
module Checkoff
  VERSION = T.let('0.212.0', T.untyped)

  # Move tasks from one place to another
  class MvSubcommand
    # sord omit - no YARD type given for "from_workspace_arg", using untyped
    # sord omit - no YARD type given for "from_project_arg", using untyped
    # sord omit - no YARD type given for "from_section_arg", using untyped
    # sord omit - no YARD return type given, using untyped
    sig { params(from_workspace_arg: T.untyped, from_project_arg: T.untyped, from_section_arg: T.untyped).returns(T.untyped) }
    def validate_and_assign_from_location(from_workspace_arg, from_project_arg, from_section_arg); end

    # sord omit - no YARD type given for "to_project_arg", using untyped
    # sord omit - no YARD return type given, using untyped
    sig { params(to_project_arg: T.untyped).returns(T.untyped) }
    def create_to_project_name(to_project_arg); end

    # sord omit - no YARD type given for "to_section_arg", using untyped
    # sord omit - no YARD return type given, using untyped
    sig { params(to_section_arg: T.untyped).returns(T.untyped) }
    def create_to_section_name(to_section_arg); end

    # sord omit - no YARD type given for "to_workspace_arg", using untyped
    # sord omit - no YARD type given for "to_project_arg", using untyped
    # sord omit - no YARD type given for "to_section_arg", using untyped
    # sord omit - no YARD return type given, using untyped
    sig { params(to_workspace_arg: T.untyped, to_project_arg: T.untyped, to_section_arg: T.untyped).returns(T.untyped) }
    def validate_and_assign_to_location(to_workspace_arg, to_project_arg, to_section_arg); end

    # sord omit - no YARD type given for "from_workspace_arg:", using untyped
    # sord omit - no YARD type given for "from_project_arg:", using untyped
    # sord omit - no YARD type given for "from_section_arg:", using untyped
    # sord omit - no YARD type given for "to_workspace_arg:", using untyped
    # sord omit - no YARD type given for "to_project_arg:", using untyped
    # sord omit - no YARD type given for "to_section_arg:", using untyped
    # sord omit - no YARD type given for "config:", using untyped
    # sord omit - no YARD type given for "projects:", using untyped
    # sord omit - no YARD type given for "sections:", using untyped
    # sord omit - no YARD type given for "logger:", using untyped
    sig do
      params(
        from_workspace_arg: T.untyped,
        from_project_arg: T.untyped,
        from_section_arg: T.untyped,
        to_workspace_arg: T.untyped,
        to_project_arg: T.untyped,
        to_section_arg: T.untyped,
        config: T.untyped,
        projects: T.untyped,
        sections: T.untyped,
        logger: T.untyped
      ).void
    end
    def initialize(from_workspace_arg:, from_project_arg:, from_section_arg:, to_workspace_arg:, to_project_arg:, to_section_arg:, config: Checkoff::Internal::ConfigLoader.load(:asana), projects: Checkoff::Projects.new(config: config), sections: Checkoff::Sections.new(config: config), logger: $stderr); end

    # sord omit - no YARD type given for "tasks", using untyped
    # sord omit - no YARD type given for "to_project", using untyped
    # sord omit - no YARD type given for "to_section", using untyped
    # sord omit - no YARD return type given, using untyped
    sig { params(tasks: T.untyped, to_project: T.untyped, to_section: T.untyped).returns(T.untyped) }
    def move_tasks(tasks, to_project, to_section); end

    # sord omit - no YARD type given for "from_workspace_name", using untyped
    # sord omit - no YARD type given for "from_project_name", using untyped
    # sord omit - no YARD type given for "from_section_name", using untyped
    # sord omit - no YARD return type given, using untyped
    sig { params(from_workspace_name: T.untyped, from_project_name: T.untyped, from_section_name: T.untyped).returns(T.untyped) }
    def fetch_tasks(from_workspace_name, from_project_name, from_section_name); end

    # sord omit - no YARD return type given, using untyped
    sig { returns(T.untyped) }
    def run; end

    # sord omit - no YARD type given for "project_arg", using untyped
    # sord omit - no YARD return type given, using untyped
    sig { params(project_arg: T.untyped).returns(T.untyped) }
    def project_arg_to_name(project_arg); end

    # sord omit - no YARD type given for :from_workspace_name, using untyped
    # Returns the value of attribute from_workspace_name.
    sig { returns(T.untyped) }
    attr_reader :from_workspace_name

    # sord omit - no YARD type given for :from_project_name, using untyped
    # Returns the value of attribute from_project_name.
    sig { returns(T.untyped) }
    attr_reader :from_project_name

    # sord omit - no YARD type given for :from_section_name, using untyped
    # Returns the value of attribute from_section_name.
    sig { returns(T.untyped) }
    attr_reader :from_section_name

    # sord omit - no YARD type given for :to_workspace_name, using untyped
    # Returns the value of attribute to_workspace_name.
    sig { returns(T.untyped) }
    attr_reader :to_workspace_name

    # sord omit - no YARD type given for :to_project_name, using untyped
    # Returns the value of attribute to_project_name.
    sig { returns(T.untyped) }
    attr_reader :to_project_name

    # sord omit - no YARD type given for :to_section_name, using untyped
    # Returns the value of attribute to_section_name.
    sig { returns(T.untyped) }
    attr_reader :to_section_name

    # sord omit - no YARD type given for :projects, using untyped
    # Returns the value of attribute projects.
    sig { returns(T.untyped) }
    attr_reader :projects

    # sord omit - no YARD type given for :sections, using untyped
    # Returns the value of attribute sections.
    sig { returns(T.untyped) }
    attr_reader :sections
  end

  # CLI subcommand that shows tasks in JSON form
  class ViewSubcommand
    # sord omit - no YARD type given for "workspace_name", using untyped
    # sord omit - no YARD type given for "project_name", using untyped
    # sord omit - no YARD type given for "section_name", using untyped
    # sord omit - no YARD type given for "task_name", using untyped
    # sord omit - no YARD type given for "config:", using untyped
    # sord omit - no YARD type given for "projects:", using untyped
    # sord omit - no YARD type given for "sections:", using untyped
    # sord omit - no YARD type given for "tasks:", using untyped
    # sord omit - no YARD type given for "stderr:", using untyped
    sig do
      params(
        workspace_name: T.untyped,
        project_name: T.untyped,
        section_name: T.untyped,
        task_name: T.untyped,
        config: T.untyped,
        projects: T.untyped,
        sections: T.untyped,
        tasks: T.untyped,
        stderr: T.untyped
      ).void
    end
    def initialize(workspace_name, project_name, section_name, task_name, config: Checkoff::Internal::ConfigLoader.load(:asana), projects: Checkoff::Projects.new(config: config), sections: Checkoff::Sections.new(config: config,
                                                    projects: projects), tasks: Checkoff::Tasks.new(config: config,
                                              sections: sections), stderr: $stderr); end

    # sord omit - no YARD return type given, using untyped
    sig { returns(T.untyped) }
    def run; end

    # sord omit - no YARD type given for "project_name", using untyped
    # sord omit - no YARD return type given, using untyped
    sig { params(project_name: T.untyped).returns(T.untyped) }
    def validate_and_assign_project_name(project_name); end

    # sord omit - no YARD type given for "workspace", using untyped
    # sord omit - no YARD type given for "project", using untyped
    # sord omit - no YARD return type given, using untyped
    sig { params(workspace: T.untyped, project: T.untyped).returns(T.untyped) }
    def run_on_project(workspace, project); end

    # sord omit - no YARD type given for "workspace", using untyped
    # sord omit - no YARD type given for "project", using untyped
    # sord omit - no YARD type given for "section", using untyped
    # sord omit - no YARD return type given, using untyped
    sig { params(workspace: T.untyped, project: T.untyped, section: T.untyped).returns(T.untyped) }
    def run_on_section(workspace, project, section); end

    # sord omit - no YARD type given for "workspace", using untyped
    # sord omit - no YARD type given for "project", using untyped
    # sord omit - no YARD type given for "section", using untyped
    # sord omit - no YARD type given for "task_name", using untyped
    # sord omit - no YARD return type given, using untyped
    sig do
      params(
        workspace: T.untyped,
        project: T.untyped,
        section: T.untyped,
        task_name: T.untyped
      ).returns(T.untyped)
    end
    def run_on_task(workspace, project, section, task_name); end

    # sord omit - no YARD type given for "task", using untyped
    # sord omit - no YARD return type given, using untyped
    sig { params(task: T.untyped).returns(T.untyped) }
    def task_to_hash(task); end

    # sord omit - no YARD type given for "tasks", using untyped
    # sord omit - no YARD return type given, using untyped
    sig { params(tasks: T.untyped).returns(T.untyped) }
    def tasks_to_hash(tasks); end

    # sord omit - no YARD type given for :workspace_name, using untyped
    # Returns the value of attribute workspace_name.
    sig { returns(T.untyped) }
    attr_reader :workspace_name

    # sord omit - no YARD type given for :project_name, using untyped
    # Returns the value of attribute project_name.
    sig { returns(T.untyped) }
    attr_reader :project_name

    # sord omit - no YARD type given for :section_name, using untyped
    # Returns the value of attribute section_name.
    sig { returns(T.untyped) }
    attr_reader :section_name

    # sord omit - no YARD type given for :task_name, using untyped
    # Returns the value of attribute task_name.
    sig { returns(T.untyped) }
    attr_reader :task_name

    # sord omit - no YARD type given for :sections, using untyped
    # Returns the value of attribute sections.
    sig { returns(T.untyped) }
    attr_reader :sections

    # sord omit - no YARD type given for :tasks, using untyped
    # Returns the value of attribute tasks.
    sig { returns(T.untyped) }
    attr_reader :tasks

    # sord omit - no YARD type given for :stderr, using untyped
    # Returns the value of attribute stderr.
    sig { returns(T.untyped) }
    attr_reader :stderr
  end

  # CLI subcommand that creates a task
  class QuickaddSubcommand
    # sord omit - no YARD type given for "workspace_name", using untyped
    # sord omit - no YARD type given for "task_name", using untyped
    # sord omit - no YARD type given for "config:", using untyped
    # sord omit - no YARD type given for "workspaces:", using untyped
    # sord omit - no YARD type given for "tasks:", using untyped
    sig do
      params(
        workspace_name: T.untyped,
        task_name: T.untyped,
        config: T.untyped,
        workspaces: T.untyped,
        tasks: T.untyped
      ).void
    end
    def initialize(workspace_name, task_name, config: Checkoff::Internal::ConfigLoader.load(:asana), workspaces: Checkoff::Workspaces.new(config: config), tasks: Checkoff::Tasks.new(config: config)); end

    # sord omit - no YARD return type given, using untyped
    sig { returns(T.untyped) }
    def run; end

    # sord omit - no YARD type given for :workspace_name, using untyped
    # Returns the value of attribute workspace_name.
    sig { returns(T.untyped) }
    attr_reader :workspace_name

    # sord omit - no YARD type given for :task_name, using untyped
    # Returns the value of attribute task_name.
    sig { returns(T.untyped) }
    attr_reader :task_name
  end

  # Provide ability for CLI to pull Asana items
  class CheckoffGLIApp
    extend GLI::App
  end

  # Work with tags in Asana
  class Tags
    MINUTE = T.let(60, T.untyped)
    HOUR = T.let(MINUTE * 60, T.untyped)
    DAY = T.let(24 * HOUR, T.untyped)
    REALLY_LONG_CACHE_TIME = T.let(HOUR * 1, T.untyped)
    LONG_CACHE_TIME = T.let(MINUTE * 15, T.untyped)
    SHORT_CACHE_TIME = T.let(MINUTE, T.untyped)

    # sord omit - no YARD type given for "config:", using untyped
    # sord omit - no YARD type given for "clients:", using untyped
    # sord omit - no YARD type given for "client:", using untyped
    # sord omit - no YARD type given for "projects:", using untyped
    # sord omit - no YARD type given for "workspaces:", using untyped
    sig do
      params(
        config: T.untyped,
        clients: T.untyped,
        client: T.untyped,
        projects: T.untyped,
        workspaces: T.untyped
      ).void
    end
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana), clients: Checkoff::Clients.new(config: config), client: clients.client, projects: Checkoff::Projects.new(config: config, client: client), workspaces: Checkoff::Workspaces.new(config: config, client: client)); end

    # sord omit - no YARD type given for "workspace_name", using untyped
    # sord omit - no YARD type given for "tag_name", using untyped
    # sord omit - no YARD type given for "only_uncompleted:", using untyped
    # sord omit - no YARD type given for "extra_fields:", using untyped
    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    sig do
      params(
        workspace_name: T.untyped,
        tag_name: T.untyped,
        only_uncompleted: T.untyped,
        extra_fields: T.untyped
      ).returns(T::Enumerable[Asana::Resources::Task])
    end
    def tasks(workspace_name, tag_name, only_uncompleted: true, extra_fields: []); end

    # sord omit - no YARD type given for "workspace_name", using untyped
    # sord omit - no YARD type given for "tag_name", using untyped
    # sord omit - no YARD return type given, using untyped
    sig { params(workspace_name: T.untyped, tag_name: T.untyped).returns(T.untyped) }
    def tag_or_raise(workspace_name, tag_name); end

    # sord omit - no YARD type given for "workspace_name", using untyped
    # sord omit - no YARD type given for "tag_name", using untyped
    # sord omit - no YARD return type given, using untyped
    sig { params(workspace_name: T.untyped, tag_name: T.untyped).returns(T.untyped) }
    def tag(workspace_name, tag_name); end

    # sord omit - no YARD type given for "options", using untyped
    # sord omit - no YARD return type given, using untyped
    sig { params(options: T.untyped).returns(T.untyped) }
    def build_params(options); end

    # sord omit - no YARD type given for "response", using untyped
    # sord omit - no YARD return type given, using untyped
    # https://github.com/Asana/ruby-asana/blob/master/lib/asana/resource_includes/response_helper.rb#L7
    sig { params(response: T.untyped).returns(T.untyped) }
    def parse(response); end

    # sord omit - no YARD return type given, using untyped
    sig { returns(T.untyped) }
    def self.run; end

    # sord omit - no YARD type given for :workspaces, using untyped
    # Returns the value of attribute workspaces.
    sig { returns(T.untyped) }
    attr_reader :workspaces

    # sord omit - no YARD type given for :projects, using untyped
    # Returns the value of attribute projects.
    sig { returns(T.untyped) }
    attr_reader :projects

    # sord omit - no YARD type given for :client, using untyped
    # Returns the value of attribute client.
    sig { returns(T.untyped) }
    attr_reader :client
  end

  # Pull tasks from Asana
  class Tasks
    include Logging
    MINUTE = T.let(60, T.untyped)
    HOUR = T.let(MINUTE * 60, T.untyped)
    DAY = T.let(24 * HOUR, T.untyped)
    REALLY_LONG_CACHE_TIME = T.let(MINUTE * 30, T.untyped)
    LONG_CACHE_TIME = T.let(MINUTE * 15, T.untyped)
    SHORT_CACHE_TIME = T.let(MINUTE * 5, T.untyped)

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # _@param_ `config`
    # 
    # _@param_ `client`
    # 
    # _@param_ `workspaces`
    # 
    # _@param_ `sections`
    # 
    # _@param_ `portfolios`
    # 
    # _@param_ `custom_fields`
    # 
    # _@param_ `time_class`
    # 
    # _@param_ `date_class`
    # 
    # _@param_ `asana_task`
    sig do
      params(
        config: T::Hash[Symbol, Object],
        client: Asana::Client,
        workspaces: Checkoff::Workspaces,
        sections: Checkoff::Sections,
        portfolios: Checkoff::Portfolios,
        custom_fields: Checkoff::CustomFields,
        time_class: T.class_of(Time),
        date_class: T.class_of(Date),
        asana_task: T.class_of(Asana::Resources::Task)
      ).void
    end
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana), client: Checkoff::Clients.new(config: config).client, workspaces: Checkoff::Workspaces.new(config: config,
                                                        client: client), sections: Checkoff::Sections.new(config: config,
                                                    client: client), portfolios: Checkoff::Portfolios.new(config: config,
                                                        client: client), custom_fields: Checkoff::CustomFields.new(config: config,
                                                             client: client), time_class: Time, date_class: Date, asana_task: Asana::Resources::Task); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # Indicates a task is ready for a person to work on it.  This is
    # subtly different than what is used by Asana to mark a date as
    # red/green!  A task is ready if it is not dependent on an
    # incomplete task and one of these is true:
    # 
    # * start is null and due on is today
    # * start is null and due at is before now
    # * start on is today
    # * start at is before now
    # 
    # _@param_ `task`
    # 
    # _@param_ `period`
    # 
    # _@param_ `ignore_dependencies`
    sig { params(task: Asana::Resources::Task, period: Symbol, ignore_dependencies: T::Boolean).returns(T::Boolean) }
    def task_ready?(task, period: :now_or_before, ignore_dependencies: false); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # _@param_ `task`
    # 
    # _@param_ `field_name`
    # 
    # _@param_ `period` — See Checkoff::Timing#in_period?_
    sig { params(task: Asana::Resources::Task, field_name: T.any(Symbol, T::Array[T.untyped]), period: T.any(Symbol, T::Array[T.untyped])).returns(T::Boolean) }
    def in_period?(task, field_name, period); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # _@param_ `task`
    # 
    # _@param_ `field_name` — :start - start_at or start_on (first set) :due - due_at or due_on (first set) :ready - start_at or start_on or due_at or due_on (first set) :modified - modified_at [:custom_field, "foo"] - 'Date' custom field type named 'foo'
    sig { params(task: Asana::Resources::Task, field_name: T.any(Symbol, T::Array[T.untyped])).returns(T.nilable(T.any(Date, Time))) }
    def date_or_time_field_by_name(task, field_name); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # Pull a specific task by name
    # 
    # @sg-ignore
    # 
    # _@param_ `workspace_name`
    # 
    # _@param_ `project_name`
    # 
    # _@param_ `section_name`
    # 
    # _@param_ `task_name`
    # 
    # _@param_ `only_uncompleted`
    # 
    # _@param_ `extra_fields`
    sig do
      params(
        workspace_name: String,
        project_name: T.any(String, Symbol),
        task_name: String,
        section_name: T.nilable(T.any(String, Symbol)),
        only_uncompleted: T::Boolean,
        extra_fields: T::Array[String]
      ).returns(T.nilable(Asana::Resources::Task))
    end
    def task(workspace_name, project_name, task_name, section_name: :unspecified, only_uncompleted: true, extra_fields: []); end

    # @sg-ignore
    # 
    # _@param_ `workspace_name`
    # 
    # _@param_ `project_name`
    # 
    # _@param_ `section_name`
    # 
    # _@param_ `task_name`
    sig do
      params(
        workspace_name: String,
        project_name: T.any(String, Symbol),
        section_name: T.nilable(T.any(String, Symbol)),
        task_name: String
      ).returns(T.nilable(String))
    end
    def gid_for_task(workspace_name, project_name, section_name, task_name); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # Pull a specific task by GID
    # 
    # _@param_ `task_gid`
    # 
    # _@param_ `extra_fields`
    # 
    # _@param_ `only_uncompleted`
    sig { params(task_gid: String, extra_fields: T::Array[String], only_uncompleted: T::Boolean).returns(T.nilable(Asana::Resources::Task)) }
    def task_by_gid(task_gid, extra_fields: [], only_uncompleted: true); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # Add a task
    # 
    # _@param_ `name`
    # 
    # _@param_ `workspace_gid`
    # 
    # _@param_ `assignee_gid`
    sig { params(name: String, workspace_gid: String, assignee_gid: String).returns(Asana::Resources::Task) }
    def add_task(name, workspace_gid: @workspaces.default_workspace_gid, assignee_gid: default_assignee_gid); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # Return user-accessible URL for a task
    # 
    # _@param_ `task`
    # 
    # _@return_ — end-user URL to the task in question
    sig { params(task: Asana::Resources::Task).returns(String) }
    def url_of_task(task); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # True if any of the task's dependencies are marked incomplete
    # 
    # Include 'dependencies.gid' in extra_fields of task passed in.
    # 
    # _@param_ `task`
    sig { params(task: Asana::Resources::Task).returns(T::Boolean) }
    def incomplete_dependencies?(task); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # _@param_ `task`
    # 
    # _@param_ `extra_task_fields`
    sig { params(task: Asana::Resources::Task, extra_task_fields: T::Array[String]).returns(T::Array[T::Hash[T.untyped, T.untyped]]) }
    def all_dependent_tasks(task, extra_task_fields: []); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # Builds on the standard API representation of an Asana task with some
    # convenience keys:
    # 
    # <regular keys from API response>
    # +
    # unwrapped:
    #  membership_by_section_gid: Hash<String, Hash (membership)>
    #  membership_by_project_gid: Hash<String, Hash (membership)>
    #  membership_by_project_name: Hash<String, Hash (membership)>
    # task: String (name)
    # 
    # _@param_ `task`
    sig { params(task: Asana::Resources::Task).returns(T::Hash[T.untyped, T.untyped]) }
    def task_to_h(task); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # _@param_ `task_data`
    sig { params(task_data: T::Hash[T.untyped, T.untyped]).returns(Asana::Resources::Task) }
    def h_to_task(task_data); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # True if the task is in a project which is in the given portfolio
    # 
    # _@param_ `task`
    # 
    # _@param_ `portfolio_name`
    # 
    # _@param_ `workspace_name`
    sig { params(task: Asana::Resources::Task, portfolio_name: String, workspace_name: String).returns(T::Boolean) }
    def in_portfolio_named?(task, portfolio_name, workspace_name: @workspaces.default_workspace.name); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # True if the task is in a project which is in the given portfolio
    # 
    # _@param_ `task`
    # 
    # _@param_ `portfolio_name`
    # 
    # _@param_ `workspace_name`
    sig { params(task: Asana::Resources::Task, portfolio_name: String, workspace_name: String).returns(T::Boolean) }
    def in_portfolio_more_than_once?(task, portfolio_name, workspace_name: @workspaces.default_workspace.name); end

    sig { returns(T::Hash[T.untyped, T.untyped]) }
    def as_cache_key; end

    sig { returns(Checkoff::Internal::TaskTiming) }
    def task_timing; end

    sig { returns(Checkoff::Internal::TaskHashes) }
    def task_hashes; end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # _@param_ `workspace_name`
    # 
    # _@param_ `project_name`
    # 
    # _@param_ `section_name`
    # 
    # _@param_ `only_uncompleted`
    # 
    # _@param_ `extra_fields`
    sig do
      params(
        workspace_name: String,
        project_name: T.any(String, Symbol),
        only_uncompleted: T::Boolean,
        extra_fields: T::Array[String],
        section_name: T.nilable(T.any(String, Symbol))
      ).returns(T::Enumerable[Asana::Resources::Task])
    end
    def tasks(workspace_name, project_name, only_uncompleted:, extra_fields: [], section_name: :unspecified); end

    sig { returns(Checkoff::Projects) }
    def projects; end

    # @sg-ignore
    sig { returns(String) }
    def default_assignee_gid; end

    sig { returns(::Logger) }
    def logger; end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def error(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def warn(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def info(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def debug(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def finer(message = nil, &block); end

    # @sg-ignore
    sig { returns(Symbol) }
    def log_level; end

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    sig { returns(Asana::Client) }
    attr_reader :client

    sig { returns(Checkoff::Timing) }
    attr_reader :timing

    sig { returns(Checkoff::CustomFields) }
    attr_reader :custom_fields
  end

  # Methods related to the Asana events / webhooks APIs
  class Events
    include Logging
    extend CacheMethod::ClassMethods
    MINUTE = T.let(60, T.untyped)
    HOUR = T.let(MINUTE * 60, T.untyped)
    DAY = T.let(24 * HOUR, T.untyped)
    REALLY_LONG_CACHE_TIME = T.let(HOUR * 1, T.untyped)
    LONG_CACHE_TIME = T.let(MINUTE * 15, T.untyped)
    SHORT_CACHE_TIME = T.let(MINUTE, T.untyped)

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    # _@param_ `config`
    # 
    # _@param_ `workspaces`
    # 
    # _@param_ `tasks`
    # 
    # _@param_ `sections`
    # 
    # _@param_ `projects`
    # 
    # _@param_ `clients`
    # 
    # _@param_ `client`
    # 
    # _@param_ `asana_event_filter_class`
    # 
    # _@param_ `asana_event_enrichment`
    sig do
      params(
        config: T::Hash[T.untyped, T.untyped],
        workspaces: Checkoff::Workspaces,
        tasks: Checkoff::Tasks,
        sections: Checkoff::Sections,
        projects: Checkoff::Projects,
        clients: Checkoff::Clients,
        client: Asana::Client,
        asana_event_filter_class: T.class_of(Checkoff::Internal::AsanaEventFilter),
        asana_event_enrichment: Checkoff::Internal::AsanaEventEnrichment
      ).void
    end
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana), workspaces: Checkoff::Workspaces.new(config: config), tasks: Checkoff::Tasks.new(config: config), sections: Checkoff::Sections.new(config: config), projects: Checkoff::Projects.new(config: config), clients: Checkoff::Clients.new(config: config), client: clients.client, asana_event_filter_class: Checkoff::Internal::AsanaEventFilter, asana_event_enrichment: Checkoff::Internal::AsanaEventEnrichment.new); end

    # _@param_ `filters` — The filters to match against
    # 
    # _@param_ `asana_events` — The events that Asana sent
    # 
    # _@return_ — The events that should be acted on
    sig { params(filters: T.nilable(T::Array[T::Hash[T.untyped, T.untyped]]), asana_events: T::Array[T::Hash[T.untyped, T.untyped]]).returns(T::Array[T::Hash[T.untyped, T.untyped]]) }
    def filter_asana_events(filters, asana_events); end

    # Add useful info (like resource task names) into an event for
    # human consumption
    # 
    # _@param_ `asana_event`
    sig { params(asana_event: T::Hash[T.untyped, T.untyped]).returns(T::Hash[T.untyped, T.untyped]) }
    def enrich_event(asana_event); end

    # sord warn - "[String" does not appear to be a type
    # sord warn - "Array<String>]" does not appear to be a type
    # sord warn - Invalid hash, must have exactly two types: "Hash<String,[String,Array<String>]>".
    # sord warn - "[String" does not appear to be a type
    # sord warn - "Array<String>]" does not appear to be a type
    # sord warn - Invalid hash, must have exactly two types: "Hash<String,[String,Array<String>]>".
    # _@param_ `filter`
    sig { params(filter: T.untyped).returns(T.untyped) }
    def enrich_filter(filter); end

    # _@param_ `webhook_subscription` — Hash of the request made to webhook POST endpoint - https://app.asana.com/api/1.0/webhooks https://developers.asana.com/reference/createwebhook
    sig { params(webhook_subscription: T::Hash[T.untyped, T.untyped]).void }
    def enrich_webhook_subscription!(webhook_subscription); end

    sig { void }
    def self.run; end

    sig { returns(::Logger) }
    def logger; end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def error(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def warn(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def info(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def debug(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def finer(message = nil, &block); end

    # @sg-ignore
    sig { returns(Symbol) }
    def log_level; end

    sig { returns(Checkoff::Projects) }
    attr_reader :projects

    sig { returns(Checkoff::Sections) }
    attr_reader :sections

    sig { returns(Checkoff::Tasks) }
    attr_reader :tasks

    sig { returns(Checkoff::Workspaces) }
    attr_reader :workspaces

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    sig { returns(Asana::Client) }
    attr_reader :client

    sig { returns(Checkoff::Internal::AsanaEventEnrichment) }
    attr_reader :asana_event_enrichment
  end

  # Common vocabulary for managing time and time periods
  class Timing
    include Logging
    MINUTE = T.let(60, T.untyped)
    HOUR = T.let(MINUTE * 60, T.untyped)
    DAY = T.let(24 * HOUR, T.untyped)
    REALLY_LONG_CACHE_TIME = T.let(HOUR * 1, T.untyped)
    LONG_CACHE_TIME = T.let(MINUTE * 15, T.untyped)
    SHORT_CACHE_TIME = T.let(MINUTE, T.untyped)
    WDAY_FROM_DAY_OF_WEEK = T.let({
  monday: 1,
  tuesday: 2,
  wednesday: 3,
  thursday: 4,
  friday: 5,
  saturday: 6,
  sunday: 0,
}.freeze, T.untyped)

    # _@param_ `today_getter`
    # 
    # _@param_ `now_getter`
    sig { params(today_getter: T.class_of(Date), now_getter: T.class_of(Time)).void }
    def initialize(today_getter: Date, now_getter: Time); end

    # _@param_ `date_or_time`
    # 
    # _@param_ `period` — Valid values: :this_week, :now_or_before, :indefinite, [:less_than_n_days_ago, Integer]
    sig { params(date_or_time: T.nilable(T.any(Date, Time)), period: T.any(Symbol, T::Array[[Symbol, Integer]])).returns(T::Boolean) }
    def in_period?(date_or_time, period); end

    # _@param_ `date_or_time`
    # 
    # _@param_ `num_days`
    sig { params(date_or_time: T.nilable(T.any(Date, Time)), num_days: Integer).returns(T::Boolean) }
    def greater_than_or_equal_to_n_days_from_today?(date_or_time, num_days); end

    # _@param_ `date_or_time`
    # 
    # _@param_ `num_days`
    sig { params(date_or_time: T.nilable(T.any(Date, Time)), num_days: Integer).returns(T::Boolean) }
    def greater_than_or_equal_to_n_days_from_now?(date_or_time, num_days); end

    # _@param_ `date_or_time`
    # 
    # _@param_ `num_days`
    sig { params(date_or_time: T.nilable(T.any(Date, Time)), num_days: Integer).returns(T::Boolean) }
    def less_than_n_days_ago?(date_or_time, num_days); end

    # _@param_ `date_or_time`
    # 
    # _@param_ `num_days`
    sig { params(date_or_time: T.nilable(T.any(Date, Time)), num_days: Integer).returns(T::Boolean) }
    def less_than_n_days_from_now?(date_or_time, num_days); end

    # _@param_ `date_or_time`
    sig { params(date_or_time: T.nilable(T.any(Date, Time))).returns(T::Boolean) }
    def this_week?(date_or_time); end

    # _@param_ `date_or_time`
    sig { params(date_or_time: T.nilable(T.any(Date, Time))).returns(T::Boolean) }
    def next_week?(date_or_time); end

    # _@param_ `date_or_time`
    # 
    # _@param_ `day_of_week`
    sig { params(date_or_time: T.nilable(T.any(Date, Time)), day_of_week: Symbol).returns(T::Boolean) }
    def day_of_week?(date_or_time, day_of_week); end

    # _@param_ `date_or_time`
    sig { params(date_or_time: T.nilable(T.any(Date, Time))).returns(T::Boolean) }
    def now_or_before?(date_or_time); end

    # _@param_ `num_days`
    sig { params(num_days: Integer).returns(Time) }
    def n_days_from_now(num_days); end

    # _@param_ `num_days`
    sig { params(num_days: Integer).returns(Date) }
    def n_days_from_today(num_days); end

    # _@param_ `date_or_time`
    # 
    # _@param_ `beginning_num_days_from_now`
    # 
    # _@param_ `end_num_days_from_now`
    sig { params(date_or_time: T.nilable(T.any(Date, Time)), beginning_num_days_from_now: T.nilable(Integer), end_num_days_from_now: T.nilable(Integer)).returns(T::Boolean) }
    def between_relative_days?(date_or_time, beginning_num_days_from_now, end_num_days_from_now); end

    # _@param_ `date_or_time`
    # 
    # _@param_ `period_name`
    # 
    # _@param_ `args`
    sig { params(date_or_time: T.nilable(T.any(Date, Time)), period_name: Symbol, args: Object).returns(T::Boolean) }
    def compound_in_period?(date_or_time, period_name, *args); end

    sig { void }
    def self.run; end

    sig { returns(::Logger) }
    def logger; end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def error(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def warn(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def info(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def debug(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def finer(message = nil, &block); end

    # @sg-ignore
    sig { returns(Symbol) }
    def log_level; end
  end

  # Pulls a configured Asana client object which can be used to access the API
  class Clients
    MINUTE = T.let(60, T.untyped)
    HOUR = T.let(MINUTE * 60, T.untyped)
    DAY = T.let(24 * HOUR, T.untyped)
    REALLY_LONG_CACHE_TIME = T.let(HOUR * 1, T.untyped)
    LONG_CACHE_TIME = T.let(MINUTE * 15, T.untyped)
    SHORT_CACHE_TIME = T.let(MINUTE, T.untyped)

    # sord omit - no YARD type given for "config:", using untyped
    # sord omit - no YARD type given for "asana_client_class:", using untyped
    sig { params(config: T.untyped, asana_client_class: T.untyped).void }
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana), asana_client_class: Asana::Client); end

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    sig { returns(Asana::Client) }
    def client; end

    # sord omit - no YARD return type given, using untyped
    sig { returns(T.untyped) }
    def self.run; end

    # sord omit - no YARD type given for :workspaces, using untyped
    # Returns the value of attribute workspaces.
    sig { returns(T.untyped) }
    attr_reader :workspaces
  end

  # Query different sections of Asana 'My Tasks' projects
  class MyTasks
    MINUTE = T.let(60, T.untyped)
    LONG_CACHE_TIME = T.let(MINUTE * 15, T.untyped)
    SHORT_CACHE_TIME = T.let(MINUTE * 5, T.untyped)

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    # _@param_ `config`
    # 
    # _@param_ `client`
    # 
    # _@param_ `projects`
    sig { params(config: T::Hash[Symbol, Object], client: Asana::Client, projects: Checkoff::Projects).void }
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana), client: Checkoff::Clients.new(config: config).client, projects: Checkoff::Projects.new(config: config,
                                                    client: client)); end

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # Given a 'My Tasks' project object, pull all tasks, then provide
    # a Hash of tasks with section name -> task list of the
    # uncompleted tasks.
    # 
    # _@param_ `project`
    # 
    # _@param_ `only_uncompleted`
    # 
    # _@param_ `extra_fields`
    sig { params(project: Asana::Resources::Project, only_uncompleted: T::Boolean, extra_fields: T::Array[String]).returns(T::Hash[String, T::Enumerable[Asana::Resources::Task]]) }
    def tasks_by_section_for_my_tasks(project, only_uncompleted: true, extra_fields: []); end

    # _@param_ `name`
    sig { params(name: String).returns(T.nilable(String)) }
    def section_key(name); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # Given a list of tasks in 'My Tasks', pull a Hash of tasks with
    # section name -> task list
    # 
    # _@param_ `tasks`
    # 
    # _@param_ `project_gid`
    sig { params(tasks: T::Enumerable[Asana::Resources::Task], project_gid: String).returns(T::Hash[String, T::Enumerable[Asana::Resources::Task]]) }
    def by_my_tasks_section(tasks, project_gid); end

    sig { returns(Checkoff::Projects) }
    attr_reader :projects

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    sig { returns(Asana::Client) }
    attr_reader :client
  end

  # Work with projects in Asana
  class Projects
    include Logging
    extend CacheMethod::ClassMethods
    MINUTE = T.let(60, T.untyped)
    HOUR = T.let(MINUTE * 60, T.untyped)
    DAY = T.let(24 * HOUR, T.untyped)
    REALLY_LONG_CACHE_TIME = T.let(MINUTE * 30, T.untyped)
    LONG_CACHE_TIME = T.let(MINUTE * 15, T.untyped)
    MEDIUM_CACHE_TIME = T.let(MINUTE * 5, T.untyped)
    SHORT_CACHE_TIME = T.let(MINUTE, T.untyped)

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    # _@param_ `config`
    # 
    # _@param_ `client`
    # 
    # _@param_ `workspaces`
    # 
    # _@param_ `project_hashes`
    # 
    # _@param_ `project_timing`
    # 
    # _@param_ `timing`
    sig do
      params(
        config: T::Hash[Symbol, Object],
        client: Asana::Client,
        workspaces: Checkoff::Workspaces,
        project_hashes: Checkoff::Internal::ProjectHashes,
        project_timing: Checkoff::Internal::ProjectTiming,
        timing: Checkoff::Timing
      ).void
    end
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana), client: Checkoff::Clients.new(config: config).client, workspaces: Checkoff::Workspaces.new(config: config,
                                                        client: client), project_hashes: Checkoff::Internal::ProjectHashes.new, project_timing: Checkoff::Internal::ProjectTiming.new(client: client), timing: Checkoff::Timing.new); end

    # _@param_ `extra_fields`
    sig { params(extra_fields: T::Array[String]).returns(T::Array[String]) }
    def task_fields(extra_fields: []); end

    # Default options used in Asana API to pull tasks
    # 
    # _@param_ `extra_fields`
    # 
    # _@param_ `only_uncompleted`
    sig { params(extra_fields: T::Array[String], only_uncompleted: T::Boolean).returns(T::Hash[Symbol, Object]) }
    def task_options(extra_fields: [], only_uncompleted: false); end

    # _@param_ `extra_project_fields`
    sig { params(extra_project_fields: T::Array[String]).returns(T::Array[String]) }
    def project_fields(extra_project_fields: []); end

    # Default options used in Asana API to pull projects
    # 
    # _@param_ `extra_project_fields`
    sig { params(extra_project_fields: T::Array[String]).returns(T::Hash[Symbol, Object]) }
    def project_options(extra_project_fields: []); end

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # pulls an Asana API project class given a name
    # 
    # _@param_ `workspace_name`
    # 
    # _@param_ `project_name`
    # 
    # _@param_ `extra_fields`
    sig { params(workspace_name: String, project_name: T.any(String, Symbol), extra_fields: T::Array[String]).returns(T.nilable(Asana::Resources::Project)) }
    def project(workspace_name, project_name, extra_fields: []); end

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # _@param_ `workspace_name`
    # 
    # _@param_ `project_name`
    # 
    # _@param_ `extra_fields`
    sig { params(workspace_name: String, project_name: T.any(String, Symbol), extra_fields: T::Array[String]).returns(Asana::Resources::Project) }
    def project_or_raise(workspace_name, project_name, extra_fields: []); end

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # _@param_ `gid`
    # 
    # _@param_ `extra_fields`
    sig { params(gid: String, extra_fields: T::Array[String]).returns(T.nilable(Asana::Resources::Project)) }
    def project_by_gid(gid, extra_fields: []); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # find uncompleted tasks in a list
    # 
    # _@param_ `tasks`
    sig { params(tasks: T::Enumerable[Asana::Resources::Task]).returns(T::Enumerable[Asana::Resources::Task]) }
    def active_tasks(tasks); end

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # Pull task objects from a named project
    # 
    # _@param_ `project`
    # 
    # _@param_ `only_uncompleted`
    # 
    # _@param_ `extra_fields`
    sig { params(project: Asana::Resources::Project, only_uncompleted: T::Boolean, extra_fields: T::Array[String]).returns(T::Enumerable[Asana::Resources::Task]) }
    def tasks_from_project(project, only_uncompleted: true, extra_fields: []); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # Pull task objects from a project identified by a gid
    # 
    # _@param_ `project_gid`
    # 
    # _@param_ `only_uncompleted`
    # 
    # _@param_ `extra_fields`
    sig { params(project_gid: String, only_uncompleted: T::Boolean, extra_fields: T::Array[String]).returns(T::Enumerable[Asana::Resources::Task]) }
    def tasks_from_project_gid(project_gid, only_uncompleted: true, extra_fields: []); end

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # _@param_ `workspace_name`
    # 
    # _@param_ `extra_fields`
    sig { params(workspace_name: String, extra_fields: T::Array[String]).returns(T::Enumerable[Asana::Resources::Project]) }
    def projects_by_workspace_name(workspace_name, extra_fields: []); end

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # _@param_ `project_obj`
    # 
    # _@param_ `project`
    sig { params(project_obj: Asana::Resources::Project, project: T.any(String, Symbol)).returns(T::Hash[T.untyped, T.untyped]) }
    def project_to_h(project_obj, project: :not_specified); end

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # Indicates a project is ready for a person to work on it.  This
    # is subtly different than what is used by Asana to mark a date as
    # red/green!
    # 
    # A project is ready if there is no start date, or if the start
    # date is today or in the past.
    # 
    # _@param_ `project`
    # 
    # _@param_ `period`
    sig { params(project: Asana::Resources::Project, period: Symbol).returns(T::Boolean) }
    def project_ready?(project, period: :now_or_before); end

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # _@param_ `project`
    # 
    # _@param_ `field_name`
    # 
    # _@param_ `period` — See Checkoff::Timing#in_period?
    sig { params(project: Asana::Resources::Project, field_name: T.any(Symbol, T::Array[T.untyped]), period: T.any(Symbol, T::Array[T.untyped])).returns(T::Boolean) }
    def in_period?(project, field_name, period); end

    sig { returns(T::Hash[T.untyped, T.untyped]) }
    def as_cache_key; end

    # sord warn - Asana::ProxiedResourceClasses::Project wasn't able to be resolved to a constant in this project
    sig { returns(Asana::ProxiedResourceClasses::Project) }
    def projects; end

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # _@param_ `workspace_name`
    sig { params(workspace_name: String).returns(Asana::Resources::Project) }
    def my_tasks(workspace_name); end

    sig { returns(::Logger) }
    def logger; end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def error(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def warn(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def info(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def debug(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def finer(message = nil, &block); end

    # @sg-ignore
    sig { returns(Symbol) }
    def log_level; end

    sig { returns(Checkoff::Timing) }
    attr_reader :timing

    sig { returns(Checkoff::Internal::ProjectTiming) }
    attr_reader :project_timing

    sig { returns(Checkoff::Internal::ProjectHashes) }
    attr_reader :project_hashes

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    sig { returns(Asana::Client) }
    attr_reader :client
  end

  # Query different sections of Asana projects
  class Sections
    include Logging
    extend CacheMethod::ClassMethods
    extend Forwardable
    MINUTE = T.let(60, T.untyped)
    HOUR = T.let(MINUTE * 60, T.untyped)
    REALLY_LONG_CACHE_TIME = T.let(MINUTE * 30, T.untyped)
    LONG_CACHE_TIME = T.let(MINUTE * 15, T.untyped)
    SHORT_CACHE_TIME = T.let(MINUTE * 5, T.untyped)

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    # _@param_ `config`
    # 
    # _@param_ `client`
    # 
    # _@param_ `projects`
    # 
    # _@param_ `workspaces`
    # 
    # _@param_ `time`
    sig do
      params(
        config: T::Hash[Symbol, Object],
        client: Asana::Client,
        projects: Checkoff::Projects,
        workspaces: Checkoff::Workspaces,
        time: T.class_of(Time)
      ).void
    end
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana), client: Checkoff::Clients.new(config: config).client, projects: Checkoff::Projects.new(config: config,
                                                    client: client), workspaces: Checkoff::Workspaces.new(config: config,
                                                        client: client), time: Time); end

    # sord warn - Asana::Resources::Section wasn't able to be resolved to a constant in this project
    # Returns a list of Asana API section objects for a given project
    # 
    # _@param_ `workspace_name`
    # 
    # _@param_ `project_name`
    # 
    # _@param_ `extra_fields`
    sig { params(workspace_name: String, project_name: T.any(String, Symbol), extra_fields: T::Array[String]).returns(T::Enumerable[Asana::Resources::Section]) }
    def sections_or_raise(workspace_name, project_name, extra_fields: []); end

    # sord warn - Asana::Resources::Section wasn't able to be resolved to a constant in this project
    # Returns a list of Asana API section objects for a given project GID
    # 
    # _@param_ `project_gid`
    # 
    # _@param_ `extra_fields`
    sig { params(project_gid: String, extra_fields: T::Array[String]).returns(T::Enumerable[Asana::Resources::Section]) }
    def sections_by_project_gid(project_gid, extra_fields: []); end

    # sord warn - "[String" does not appear to be a type
    # sord warn - "nil]" does not appear to be a type
    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # sord warn - Invalid hash, must have exactly two types: "Hash{[String, nil] => Enumerable<Asana::Resources::Task>}".
    # Given a workspace name and project name, then provide a Hash of
    # tasks with section name -> task list of the uncompleted tasks
    # 
    # _@param_ `workspace_name`
    # 
    # _@param_ `project_name`
    # 
    # _@param_ `only_uncompleted`
    # 
    # _@param_ `extra_fields`
    sig do
      params(
        workspace_name: String,
        project_name: T.any(String, Symbol),
        only_uncompleted: T::Boolean,
        extra_fields: T::Array[String]
      ).returns(T.untyped)
    end
    def tasks_by_section(workspace_name, project_name, only_uncompleted: true, extra_fields: []); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # _@param_ `section_gid`
    # 
    # _@param_ `only_uncompleted`
    # 
    # _@param_ `extra_fields`
    sig { params(section_gid: String, only_uncompleted: T::Boolean, extra_fields: T::Array[String]).returns(T::Enumerable[Asana::Resources::Task]) }
    def tasks_by_section_gid(section_gid, only_uncompleted: true, extra_fields: []); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # XXX: Rename to section_tasks
    # 
    # Pulls task objects from a specified section
    # 
    # _@param_ `workspace_name`
    # 
    # _@param_ `project_name`
    # 
    # _@param_ `section_name`
    # 
    # _@param_ `only_uncompleted`
    # 
    # _@param_ `extra_fields`
    sig do
      params(
        workspace_name: String,
        project_name: T.any(String, Symbol),
        section_name: T.nilable(String),
        only_uncompleted: T::Boolean,
        extra_fields: T::Array[String]
      ).returns(T::Enumerable[Asana::Resources::Task])
    end
    def tasks(workspace_name, project_name, section_name, only_uncompleted: true, extra_fields: []); end

    # Pulls just names of tasks from a given section.
    # 
    # _@param_ `workspace_name`
    # 
    # _@param_ `project_name`
    # 
    # _@param_ `section_name`
    sig { params(workspace_name: String, project_name: T.any(String, Symbol), section_name: T.nilable(String)).returns(T::Array[String]) }
    def section_task_names(workspace_name, project_name, section_name); end

    # sord warn - Asana::Resources::Section wasn't able to be resolved to a constant in this project
    # @sg-ignore
    # 
    # _@param_ `workspace_name`
    # 
    # _@param_ `project_name`
    # 
    # _@param_ `section_name`
    # 
    # _@param_ `extra_section_fields`
    sig do
      params(
        workspace_name: String,
        project_name: T.any(String, Symbol),
        section_name: T.nilable(String),
        extra_section_fields: T::Array[String]
      ).returns(Asana::Resources::Section)
    end
    def section_or_raise(workspace_name, project_name, section_name, extra_section_fields: []); end

    # _@param_ `name`
    sig { params(name: String).returns(T.nilable(String)) }
    def section_key(name); end

    # sord warn - Asana::Resources::Section wasn't able to be resolved to a constant in this project
    # sord warn - Asana::Resources::Section wasn't able to be resolved to a constant in this project
    # _@param_ `section`
    sig { params(section: Asana::Resources::Section).returns(T.nilable(Asana::Resources::Section)) }
    def previous_section(section); end

    # sord warn - Asana::Resources::Section wasn't able to be resolved to a constant in this project
    # _@param_ `gid`
    sig { params(gid: String).returns(T.nilable(Asana::Resources::Section)) }
    def section_by_gid(gid); end

    sig { returns(T::Hash[T.untyped, T.untyped]) }
    def as_cache_key; end

    # sord warn - Asana::Resources::Section wasn't able to be resolved to a constant in this project
    # @sg-ignore
    # 
    # _@param_ `workspace_name`
    # 
    # _@param_ `project_name`
    # 
    # _@param_ `section_name`
    # 
    # _@param_ `extra_section_fields`
    sig do
      params(
        workspace_name: String,
        project_name: T.any(String, Symbol),
        section_name: T.nilable(String),
        extra_section_fields: T::Array[String]
      ).returns(T.nilable(Asana::Resources::Section))
    end
    def section(workspace_name, project_name, section_name, extra_section_fields: []); end

    # sord warn - Faraday::Response wasn't able to be resolved to a constant in this project
    # https://github.com/Asana/ruby-asana/blob/master/lib/asana/resource_includes/response_helper.rb#L7
    # 
    # _@param_ `response`
    sig { params(response: Faraday::Response).returns(T::Array[T.any(T::Hash[T.untyped, T.untyped], T::Hash[T.untyped, T.untyped])]) }
    def parse(response); end

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # sord warn - "[String" does not appear to be a type
    # sord warn - "nil]" does not appear to be a type
    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # sord warn - Invalid hash, must have exactly two types: "Hash<[String,nil], Enumerable<Asana::Resources::Task>>".
    # Given a project object, pull all tasks, then provide a Hash of
    # tasks with section name -> task list of the uncompleted tasks
    # 
    # _@param_ `project`
    # 
    # _@param_ `only_uncompleted`
    # 
    # _@param_ `extra_fields`
    sig { params(project: Asana::Resources::Project, only_uncompleted: T::Boolean, extra_fields: T::Array[String]).returns(T.untyped) }
    def tasks_by_section_for_project(project, only_uncompleted: true, extra_fields: []); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # sord warn - "[String" does not appear to be a type
    # sord warn - "nil]" does not appear to be a type
    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # sord warn - Invalid hash, must have exactly two types: "Hash<[String,nil], Enumerable<Asana::Resources::Task>>".
    # Given a list of tasks, pull a Hash of tasks with section name -> task list
    # 
    # _@param_ `tasks`
    # 
    # _@param_ `project_gid`
    sig { params(tasks: T::Enumerable[Asana::Resources::Task], project_gid: String).returns(T.untyped) }
    def by_section(tasks, project_gid); end

    # sord warn - "[String" does not appear to be a type
    # sord warn - "nil]" does not appear to be a type
    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # sord warn - Invalid hash, must have exactly two types: "Hash{[String, nil] => Enumerable<Asana::Resources::Task>}".
    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # _@param_ `by_section`
    # 
    # _@param_ `task`
    # 
    # _@param_ `project_gid`
    sig { params(by_section: T.untyped, task: Asana::Resources::Task, project_gid: String).void }
    def file_task_by_section(by_section, task, project_gid); end

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # _@param_ `workspace_name`
    # 
    # _@param_ `project_name`
    sig { params(workspace_name: String, project_name: T.any(String, Symbol)).returns(Asana::Resources::Project) }
    def project_or_raise(workspace_name, project_name); end

    sig { returns(::Logger) }
    def logger; end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def error(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def warn(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def info(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def debug(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def finer(message = nil, &block); end

    # @sg-ignore
    sig { returns(Symbol) }
    def log_level; end

    sig { returns(Checkoff::Projects) }
    attr_reader :projects

    sig { returns(Checkoff::Workspaces) }
    attr_reader :workspaces

    sig { returns(T.class_of(Time)) }
    attr_reader :time

    sig { returns(Checkoff::MyTasks) }
    attr_reader :my_tasks

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    sig { returns(Asana::Client) }
    attr_reader :client
  end

  # Query different subtasks of Asana tasks
  class Subtasks
    extend CacheMethod::ClassMethods
    extend Forwardable
    MINUTE = T.let(60, T.untyped)
    LONG_CACHE_TIME = T.let(MINUTE * 15, T.untyped)
    SHORT_CACHE_TIME = T.let(MINUTE * 5, T.untyped)

    # _@param_ `config`
    # 
    # _@param_ `projects`
    # 
    # _@param_ `clients`
    sig { params(config: T::Hash[T.untyped, T.untyped], projects: Checkoff::Projects, clients: Checkoff::Clients).void }
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana), projects: Checkoff::Projects.new(config: config), clients: Checkoff::Clients.new(config: config)); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # True if all subtasks of the task are completed
    # 
    # _@param_ `task`
    sig { params(task: Asana::Resources::Task).returns(T::Boolean) }
    def all_subtasks_completed?(task); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # sord warn - "[nil" does not appear to be a type
    # sord warn - "String]" does not appear to be a type
    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # sord warn - Invalid hash, must have exactly two types: "Hash<[nil,String], Enumerable<Asana::Resources::Task>>".
    # pulls a Hash of subtasks broken out by section
    # 
    # _@param_ `tasks`
    sig { params(tasks: T::Enumerable[Asana::Resources::Task]).returns(T.untyped) }
    def by_section(tasks); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # Returns all subtasks, including section headers
    # 
    # _@param_ `task`
    sig { params(task: Asana::Resources::Task).returns(T::Enumerable[Asana::Resources::Task]) }
    def raw_subtasks(task); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # Pull a specific task by GID
    # 
    # _@param_ `task_gid`
    # 
    # _@param_ `extra_fields`
    # 
    # _@param_ `only_uncompleted`
    sig { params(task_gid: String, extra_fields: T::Array[String], only_uncompleted: T::Boolean).returns(T::Enumerable[Asana::Resources::Task]) }
    def subtasks_by_gid(task_gid, extra_fields: [], only_uncompleted: true); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # True if the subtask passed in represents a section in the subtasks
    # 
    # Note: expect this to be removed in a future version, as Asana is
    # expected to move to the new-style way of representing sections
    # as memberships with a separate API within a task.
    # 
    # _@param_ `subtask`
    sig { params(subtask: Asana::Resources::Task).returns(T::Boolean) }
    def subtask_section?(subtask); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # _@param_ `current_section`
    # 
    # _@param_ `by_section`
    # 
    # _@param_ `task`
    sig { params(current_section: T.nilable(String), by_section: T::Hash[T.untyped, T.untyped], task: Asana::Resources::Task).returns(T::Array[[String, T::Hash[T.untyped, T.untyped]]]) }
    def file_task_by_section(current_section, by_section, task); end

    sig { returns(Checkoff::Projects) }
    attr_reader :projects

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    sig { returns(Asana::Client) }
    attr_reader :client
  end

  # Deal with Asana resources across different resource types
  class Resources
    extend CacheMethod::ClassMethods
    MINUTE = T.let(60, T.untyped)
    HOUR = T.let(MINUTE * 60, T.untyped)
    DAY = T.let(24 * HOUR, T.untyped)
    REALLY_LONG_CACHE_TIME = T.let(HOUR * 1, T.untyped)
    LONG_CACHE_TIME = T.let(MINUTE * 15, T.untyped)
    SHORT_CACHE_TIME = T.let(MINUTE, T.untyped)

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    # _@param_ `config`
    # 
    # _@param_ `workspaces`
    # 
    # _@param_ `tasks`
    # 
    # _@param_ `sections`
    # 
    # _@param_ `projects`
    # 
    # _@param_ `clients`
    # 
    # _@param_ `client`
    sig do
      params(
        config: T::Hash[T.untyped, T.untyped],
        workspaces: Checkoff::Workspaces,
        tasks: Checkoff::Tasks,
        sections: Checkoff::Sections,
        projects: Checkoff::Projects,
        clients: Checkoff::Clients,
        client: Asana::Client
      ).void
    end
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana), workspaces: Checkoff::Workspaces.new(config: config), tasks: Checkoff::Tasks.new(config: config), sections: Checkoff::Sections.new(config: config), projects: Checkoff::Projects.new(config: config), clients: Checkoff::Clients.new(config: config), client: clients.client); end

    # sord warn - "[Asana::Resource" does not appear to be a type
    # sord warn - "nil]" does not appear to be a type
    # sord warn - "[String" does not appear to be a type
    # sord warn - "nil]" does not appear to be a type
    # Attempt to look up a GID, even in situations where we don't
    # have a resource type provided.
    # 
    # _@param_ `gid`
    # 
    # _@param_ `resource_type`
    sig { params(gid: String, resource_type: T.nilable(String)).returns(T::Array[[T.untyped, T.untyped, T.untyped, T.untyped]]) }
    def resource_by_gid(gid, resource_type: nil); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # _@param_ `gid`
    sig { params(gid: String).returns(T.nilable(Asana::Resources::Task)) }
    def fetch_task_gid(gid); end

    # sord warn - Asana::Resources::Section wasn't able to be resolved to a constant in this project
    # _@param_ `section_gid`
    sig { params(section_gid: String).returns(T.nilable(Asana::Resources::Section)) }
    def fetch_section_gid(section_gid); end

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # _@param_ `project_gid`
    sig { params(project_gid: String).returns(T.nilable(Asana::Resources::Project)) }
    def fetch_project_gid(project_gid); end

    sig { void }
    def self.run; end

    sig { returns(Checkoff::Workspaces) }
    attr_reader :workspaces

    sig { returns(Checkoff::Projects) }
    attr_reader :projects

    sig { returns(Checkoff::Sections) }
    attr_reader :sections

    sig { returns(Checkoff::Tasks) }
    attr_reader :tasks

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    sig { returns(Asana::Client) }
    attr_reader :client
  end

  # Manages timelines of dependent tasks with dates and milestones
  class Timelines
    extend CacheMethod::ClassMethods
    MINUTE = T.let(60, T.untyped)
    HOUR = T.let(MINUTE * 60, T.untyped)
    DAY = T.let(24 * HOUR, T.untyped)
    REALLY_LONG_CACHE_TIME = T.let(HOUR * 1, T.untyped)
    LONG_CACHE_TIME = T.let(MINUTE * 15, T.untyped)
    SHORT_CACHE_TIME = T.let(MINUTE, T.untyped)

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    # _@param_ `config`
    # 
    # _@param_ `workspaces`
    # 
    # _@param_ `sections`
    # 
    # _@param_ `tasks`
    # 
    # _@param_ `portfolios`
    # 
    # _@param_ `clients`
    # 
    # _@param_ `client`
    sig do
      params(
        config: T::Hash[T.untyped, T.untyped],
        workspaces: Checkoff::Workspaces,
        sections: Checkoff::Sections,
        tasks: Checkoff::Tasks,
        portfolios: Checkoff::Portfolios,
        clients: Checkoff::Clients,
        client: Asana::Client
      ).void
    end
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana), workspaces: Checkoff::Workspaces.new(config: config), sections: Checkoff::Sections.new(config: config), tasks: Checkoff::Tasks.new(config: config), portfolios: Checkoff::Portfolios.new(config: config), clients: Checkoff::Clients.new(config: config), client: clients.client); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # _@param_ `task`
    # 
    # _@param_ `limit_to_portfolio_gid`
    # 
    # _@param_ `project_name`
    sig { params(task: Asana::Resources::Task, limit_to_portfolio_gid: T.nilable(String)).returns(T::Boolean) }
    def task_dependent_on_previous_section_last_milestone?(task, limit_to_portfolio_gid: nil); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # _@param_ `task`
    # 
    # _@param_ `limit_to_portfolio_name`
    sig { params(task: Asana::Resources::Task, limit_to_portfolio_name: T.nilable(String)).returns(T::Boolean) }
    def last_task_milestone_depends_on_this_task?(task, limit_to_portfolio_name: nil); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # _@param_ `task`
    # 
    # _@param_ `limit_to_portfolio_name`
    sig { params(task: Asana::Resources::Task, limit_to_portfolio_name: T.nilable(String)).returns(T::Boolean) }
    def any_milestone_depends_on_this_task?(task, limit_to_portfolio_name: nil); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # _@param_ `section_gid`
    sig { params(section_gid: String).returns(T.nilable(Asana::Resources::Task)) }
    def last_milestone_in_section(section_gid); end

    # sord warn - Asana::Resources::Section wasn't able to be resolved to a constant in this project
    # _@param_ `task_data`
    # 
    # _@param_ `section`
    sig { params(task_data: T::Hash[T.untyped, T.untyped], section: Asana::Resources::Section).returns(T::Boolean) }
    def task_data_dependent_on_previous_section_last_milestone?(task_data, section); end

    sig { void }
    def self.run; end

    sig { returns(Checkoff::Workspaces) }
    attr_reader :workspaces

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    sig { returns(Asana::Client) }
    attr_reader :client
  end

  # Pull portfolios from Asana
  class Portfolios
    extend CacheMethod::ClassMethods
    MINUTE = T.let(60, T.untyped)
    HOUR = T.let(MINUTE * 60, T.untyped)
    DAY = T.let(24 * HOUR, T.untyped)
    REALLY_LONG_CACHE_TIME = T.let(HOUR * 1, T.untyped)
    LONG_CACHE_TIME = T.let(MINUTE * 15, T.untyped)
    SHORT_CACHE_TIME = T.let(MINUTE, T.untyped)

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    # _@param_ `config`
    # 
    # _@param_ `workspaces`
    # 
    # _@param_ `clients`
    # 
    # _@param_ `client`
    # 
    # _@param_ `projects`
    sig do
      params(
        config: T::Hash[T.untyped, T.untyped],
        clients: Checkoff::Clients,
        client: Asana::Client,
        projects: Checkoff::Projects,
        workspaces: Checkoff::Workspaces
      ).void
    end
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana), clients: Checkoff::Clients.new(config: config), client: clients.client, projects: Checkoff::Projects.new(config: config, client: client), workspaces: Checkoff::Workspaces.new(config: config, client: client)); end

    # sord warn - Asana::Resources::Portfolio wasn't able to be resolved to a constant in this project
    # _@param_ `workspace_name`
    # 
    # _@param_ `portfolio_name`
    sig { params(workspace_name: String, portfolio_name: String).returns(Asana::Resources::Portfolio) }
    def portfolio_or_raise(workspace_name, portfolio_name); end

    # sord warn - Asana::Resources::Portfolio wasn't able to be resolved to a constant in this project
    # @sg-ignore
    # 
    # _@param_ `workspace_name`
    # 
    # _@param_ `portfolio_name`
    sig { params(workspace_name: String, portfolio_name: String).returns(T.nilable(Asana::Resources::Portfolio)) }
    def portfolio(workspace_name, portfolio_name); end

    # sord warn - Asana::Resources::Portfolio wasn't able to be resolved to a constant in this project
    # Pull a specific portfolio by gid
    # 
    # _@param_ `portfolio_gid`
    # 
    # _@param_ `extra_fields`
    sig { params(portfolio_gid: String, extra_fields: T::Array[String]).returns(T.nilable(Asana::Resources::Portfolio)) }
    def portfolio_by_gid(portfolio_gid, extra_fields: []); end

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # _@param_ `workspace_name`
    # 
    # _@param_ `portfolio_name`
    # 
    # _@param_ `extra_project_fields`
    sig { params(workspace_name: String, portfolio_name: String, extra_project_fields: T::Array[String]).returns(T::Enumerable[Asana::Resources::Project]) }
    def projects_in_portfolio(workspace_name, portfolio_name, extra_project_fields: []); end

    # sord warn - Asana::Resources::Portfolio wasn't able to be resolved to a constant in this project
    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # _@param_ `portfolio`
    # 
    # _@param_ `extra_project_fields`
    sig { params(portfolio: Asana::Resources::Portfolio, extra_project_fields: T::Array[String]).returns(T::Enumerable[Asana::Resources::Project]) }
    def projects_in_portfolio_obj(portfolio, extra_project_fields: []); end

    sig { void }
    def self.run; end

    sig { returns(Checkoff::Workspaces) }
    attr_reader :workspaces

    sig { returns(Checkoff::Projects) }
    attr_reader :projects

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    sig { returns(Asana::Client) }
    attr_reader :client
  end

  # Query different workspaces of Asana projects
  class Workspaces
    extend CacheMethod::ClassMethods
    MINUTE = T.let(60, T.untyped)
    HOUR = T.let(MINUTE * 60, T.untyped)
    DAY = T.let(24 * HOUR, T.untyped)
    REALLY_LONG_CACHE_TIME = T.let(HOUR * 1, T.untyped)
    LONG_CACHE_TIME = T.let(MINUTE * 15, T.untyped)
    SHORT_CACHE_TIME = T.let(MINUTE, T.untyped)

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    # sord warn - Asana::Resources::Workspace wasn't able to be resolved to a constant in this project
    # _@param_ `config`
    # 
    # _@param_ `client`
    # 
    # _@param_ `asana_workspace`
    sig { params(config: T::Hash[Symbol, Object], client: Asana::Client, asana_workspace: T.class_of(Asana::Resources::Workspace)).void }
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana), client: Checkoff::Clients.new(config: config).client, asana_workspace: Asana::Resources::Workspace); end

    # sord warn - Asana::Resources::Workspace wasn't able to be resolved to a constant in this project
    # Pulls an Asana workspace object
    # @sg-ignore
    # 
    # _@param_ `workspace_name`
    sig { params(workspace_name: String).returns(T.nilable(Asana::Resources::Workspace)) }
    def workspace(workspace_name); end

    # sord warn - Asana::Resources::Workspace wasn't able to be resolved to a constant in this project
    sig { returns(Asana::Resources::Workspace) }
    def default_workspace; end

    # sord warn - Asana::Resources::Workspace wasn't able to be resolved to a constant in this project
    # _@param_ `workspace_name`
    sig { params(workspace_name: String).returns(Asana::Resources::Workspace) }
    def workspace_or_raise(workspace_name); end

    # @sg-ignore
    sig { returns(String) }
    def default_workspace_gid; end

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    sig { returns(Asana::Client) }
    attr_reader :client
  end

  # Manage attachments in Asana
  class Attachments
    include Logging
    MINUTE = T.let(60, T.untyped)
    HOUR = T.let(MINUTE * 60, T.untyped)
    DAY = T.let(24 * HOUR, T.untyped)
    REALLY_LONG_CACHE_TIME = T.let(HOUR * 1, T.untyped)
    LONG_CACHE_TIME = T.let(MINUTE * 15, T.untyped)
    SHORT_CACHE_TIME = T.let(MINUTE, T.untyped)

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    # _@param_ `config`
    # 
    # _@param_ `workspaces`
    # 
    # _@param_ `clients`
    # 
    # _@param_ `client`
    sig do
      params(
        config: T::Hash[T.untyped, T.untyped],
        workspaces: Checkoff::Workspaces,
        clients: Checkoff::Clients,
        client: Asana::Client
      ).void
    end
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana), workspaces: Checkoff::Workspaces.new(config: config), clients: Checkoff::Clients.new(config: config), client: clients.client); end

    # sord warn - OpenSSL::SSL::VERIFY_NONE wasn't able to be resolved to a constant in this project
    # sord warn - OpenSSL::SSL::VERIFY_PEER wasn't able to be resolved to a constant in this project
    # sord warn - Asana::Resources::Attachment wasn't able to be resolved to a constant in this project
    # _@param_ `url`
    # 
    # _@param_ `resource`
    # 
    # _@param_ `attachment_name`
    # 
    # _@param_ `just_the_url`
    # 
    # _@param_ `verify_mode`
    sig do
      params(
        url: String,
        resource: Asana::Resources::Resource,
        attachment_name: T.nilable(String),
        verify_mode: Integer,
        just_the_url: T::Boolean
      ).returns(Asana::Resources::Attachment)
    end
    def create_attachment_from_url!(url, resource, attachment_name: nil, verify_mode: OpenSSL::SSL::VERIFY_PEER, just_the_url: false); end

    # sord warn - URI wasn't able to be resolved to a constant in this project
    # sord warn - OpenSSL::SSL::VERIFY_NONE wasn't able to be resolved to a constant in this project
    # sord warn - OpenSSL::SSL::VERIFY_PEER wasn't able to be resolved to a constant in this project
    # Writes contents of URL to a temporary file with the same
    # extension as the URL using Net::HTTP, raising an exception if
    # not succesful
    # 
    # @sg-ignore
    # 
    # _@param_ `uri`
    # 
    # _@param_ `verify_mode`
    sig { params(uri: URI, verify_mode: T.any(OpenSSL::SSL::VERIFY_NONE, OpenSSL::SSL::VERIFY_PEER), block: T.untyped).returns(Object) }
    def download_uri(uri, verify_mode: OpenSSL::SSL::VERIFY_PEER, &block); end

    # sord warn - Net::HTTPResponse wasn't able to be resolved to a constant in this project
    # @sg-ignore
    # 
    # _@param_ `response`
    sig { params(response: Net::HTTPResponse).returns(Object) }
    def write_tempfile_from_response(response); end

    # sord warn - OpenSSL::SSL::VERIFY_NONE wasn't able to be resolved to a constant in this project
    # sord warn - OpenSSL::SSL::VERIFY_PEER wasn't able to be resolved to a constant in this project
    # sord warn - Asana::Resources::Attachment wasn't able to be resolved to a constant in this project
    # _@param_ `url`
    # 
    # _@param_ `resource`
    # 
    # _@param_ `attachment_name`
    # 
    # _@param_ `verify_mode`
    sig do
      params(
        url: String,
        resource: Asana::Resources::Resource,
        attachment_name: T.nilable(String),
        verify_mode: Integer
      ).returns(Asana::Resources::Attachment)
    end
    def create_attachment_from_downloaded_url!(url, resource, attachment_name:, verify_mode: OpenSSL::SSL::VERIFY_PEER); end

    # sord warn - Asana::Resources::Attachment wasn't able to be resolved to a constant in this project
    # _@param_ `url`
    # 
    # _@param_ `resource`
    # 
    # _@param_ `attachment_name`
    sig { params(url: String, resource: Asana::Resources::Resource, attachment_name: T.nilable(String)).returns(T.nilable(Asana::Resources::Attachment)) }
    def create_attachment_from_url_alone!(url, resource, attachment_name:); end

    # @sg-ignore
    # 
    # _@param_ `filename`
    sig { params(filename: String).returns(T.nilable(String)) }
    def content_type_from_filename(filename); end

    # sord warn - Faraday::Response wasn't able to be resolved to a constant in this project
    # https://github.com/Asana/ruby-asana/blob/master/lib/asana/resource_includes/response_helper.rb#L7
    # 
    # _@param_ `response`
    sig { params(response: Faraday::Response).returns(T::Array[T.any(T::Hash[T.untyped, T.untyped], T::Hash[T.untyped, T.untyped])]) }
    def parse(response); end

    sig { void }
    def self.run; end

    sig { returns(::Logger) }
    def logger; end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def error(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def warn(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def info(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def debug(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def finer(message = nil, &block); end

    # @sg-ignore
    sig { returns(Symbol) }
    def log_level; end

    sig { returns(Checkoff::Workspaces) }
    attr_reader :workspaces

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    sig { returns(Asana::Client) }
    attr_reader :client
  end

  # Work with custom fields in Asana
  class CustomFields
    extend CacheMethod::ClassMethods
    MINUTE = T.let(60, T.untyped)
    HOUR = T.let(MINUTE * 60, T.untyped)
    DAY = T.let(24 * HOUR, T.untyped)
    REALLY_LONG_CACHE_TIME = T.let(HOUR * 1, T.untyped)
    LONG_CACHE_TIME = T.let(MINUTE * 15, T.untyped)
    SHORT_CACHE_TIME = T.let(MINUTE, T.untyped)

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    # _@param_ `config`
    # 
    # _@param_ `workspaces`
    # 
    # _@param_ `clients`
    # 
    # _@param_ `client`
    sig do
      params(
        config: T::Hash[T.untyped, T.untyped],
        clients: Checkoff::Clients,
        client: Asana::Client,
        workspaces: Checkoff::Workspaces
      ).void
    end
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana), clients: Checkoff::Clients.new(config: config), client: clients.client, workspaces: Checkoff::Workspaces.new(config: config,
                                                        client: client)); end

    # sord warn - Asana::Resources::CustomField wasn't able to be resolved to a constant in this project
    # _@param_ `workspace_name`
    # 
    # _@param_ `custom_field_name`
    sig { params(workspace_name: String, custom_field_name: String).returns(Asana::Resources::CustomField) }
    def custom_field_or_raise(workspace_name, custom_field_name); end

    # sord warn - Asana::Resources::CustomField wasn't able to be resolved to a constant in this project
    # @sg-ignore
    # 
    # _@param_ `workspace_name`
    # 
    # _@param_ `custom_field_name`
    sig { params(workspace_name: String, custom_field_name: String).returns(T.nilable(Asana::Resources::CustomField)) }
    def custom_field(workspace_name, custom_field_name); end

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # _@param_ `resource`
    # 
    # _@param_ `custom_field_gid`
    sig { params(resource: T.any(Asana::Resources::Project, Asana::Resources::Task), custom_field_gid: String).returns(T::Array[String]) }
    def resource_custom_field_values_gids_or_raise(resource, custom_field_gid); end

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # _@param_ `resource`
    # 
    # _@param_ `custom_field_name`
    sig { params(resource: T.any(Asana::Resources::Project, Asana::Resources::Task), custom_field_name: String).returns(T::Array[String]) }
    def resource_custom_field_values_names_by_name(resource, custom_field_name); end

    # sord omit - no YARD type given for "resource", using untyped
    # @sg-ignore
    # 
    # _@param_ `project`
    # 
    # _@param_ `custom_field_name`
    sig { params(resource: T.untyped, custom_field_name: String).returns(T.nilable(T::Hash[T.untyped, T.untyped])) }
    def resource_custom_field_by_name(resource, custom_field_name); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # _@param_ `resource`
    # 
    # _@param_ `custom_field_name`
    sig { params(resource: T.any(Asana::Resources::Task, Asana::Resources::Project), custom_field_name: String).returns(T::Hash[T.untyped, T.untyped]) }
    def resource_custom_field_by_name_or_raise(resource, custom_field_name); end

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # _@param_ `resource`
    # 
    # _@param_ `custom_field_gid`
    sig { params(resource: T.any(Asana::Resources::Project, Asana::Resources::Task), custom_field_gid: String).returns(T::Hash[T.untyped, T.untyped]) }
    def resource_custom_field_by_gid_or_raise(resource, custom_field_gid); end

    # @sg-ignore
    # 
    # _@param_ `custom_field`
    sig { params(custom_field: T::Hash[T.untyped, T.untyped]).returns(T::Array[String]) }
    def resource_custom_field_enum_values(custom_field); end

    # _@param_ `custom_field`
    # 
    # _@param_ `enum_value`
    sig { params(custom_field: T::Hash[T.untyped, T.untyped], enum_value: T.nilable(Object)).returns(T::Array[String]) }
    def find_gids(custom_field, enum_value); end

    sig { void }
    def self.run; end

    sig { returns(Checkoff::Workspaces) }
    attr_reader :workspaces

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    sig { returns(Asana::Client) }
    attr_reader :client
  end

  # Run task searches against the Asana API
  class TaskSearches
    include Logging
    include Asana::Resources::ResponseHelper
    extend CacheMethod::ClassMethods
    MINUTE = T.let(60, T.untyped)
    HOUR = T.let(MINUTE * 60, T.untyped)
    DAY = T.let(24 * HOUR, T.untyped)
    REALLY_LONG_CACHE_TIME = T.let(HOUR * 1, T.untyped)
    LONG_CACHE_TIME = T.let(MINUTE * 15, T.untyped)
    SHORT_CACHE_TIME = T.let(MINUTE, T.untyped)

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    # sord warn - Asana::Resources::Collection wasn't able to be resolved to a constant in this project
    # _@param_ `config`
    # 
    # _@param_ `workspaces`
    # 
    # _@param_ `task_selectors`
    # 
    # _@param_ `projects`
    # 
    # _@param_ `clients`
    # 
    # _@param_ `client`
    # 
    # _@param_ `search_url_parser`
    # 
    # _@param_ `asana_resources_collection_class`
    sig do
      params(
        config: T::Hash[Symbol, Object],
        workspaces: Checkoff::Workspaces,
        task_selectors: Checkoff::TaskSelectors,
        projects: Checkoff::Projects,
        clients: Checkoff::Clients,
        client: Asana::Client,
        search_url_parser: Checkoff::Internal::SearchUrl::Parser,
        asana_resources_collection_class: T.class_of(Asana::Resources::Collection)
      ).void
    end
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana), workspaces: Checkoff::Workspaces.new(config: config), task_selectors: Checkoff::TaskSelectors.new(config: config), projects: Checkoff::Projects.new(config: config), clients: Checkoff::Clients.new(config: config), client: clients.client, search_url_parser: Checkoff::Internal::SearchUrl::Parser.new, asana_resources_collection_class: Asana::Resources::Collection); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # Perform an equivalent search API to an Asana search URL in the
    # web UI.  Not all URL parameters are supported; each one must be
    # added here manually.  In addition, not all are supported in the
    # Asana API in a compatible way, so they may result in more tasks
    # being fetched than actually returned as filtering is done
    # manually.
    # 
    # _@param_ `workspace_name`
    # 
    # _@param_ `url`
    # 
    # _@param_ `extra_fields`
    sig { params(workspace_name: String, url: String, extra_fields: T::Array[String]).returns(T::Enumerable[Asana::Resources::Task]) }
    def task_search(workspace_name, url, extra_fields: []); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # Perform a search using the Asana Task Search API:
    # 
    #   https://developers.asana.com/reference/searchtasksforworkspace
    # 
    # _@param_ `api_params`
    # 
    # _@param_ `workspace_gid`
    # 
    # _@param_ `extra_fields`
    # 
    # _@param_ `task_selector`
    # 
    # _@param_ `fetch_all` — Ensure all results are provided by manually paginating
    sig do
      params(
        api_params: T::Hash[Symbol, Object],
        workspace_gid: String,
        extra_fields: T::Array[String],
        task_selector: T::Array[T.untyped],
        fetch_all: T::Boolean
      ).returns(T::Enumerable[Asana::Resources::Task])
    end
    def raw_task_search(api_params, workspace_gid:, extra_fields: [], task_selector: [], fetch_all: true); end

    sig { returns(T::Hash[T.untyped, T.untyped]) }
    def as_cache_key; end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # Perform a search using the Asana Task Search API:
    # 
    #   https://developers.asana.com/reference/searchtasksforworkspace
    # 
    # _@param_ `api_params`
    # 
    # _@param_ `workspace_gid`
    # 
    # _@param_ `extra_fields`
    sig { params(api_params: T::Hash[Symbol, Object], workspace_gid: String, extra_fields: T::Array[String]).returns(T::Enumerable[Asana::Resources::Task]) }
    def api_task_search_request(api_params, workspace_gid:, extra_fields:); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # Perform a search using the Asana Task Search API and use manual pagination to
    # ensure all results are returned:
    # 
    #   https://developers.asana.com/reference/searchtasksforworkspace
    # 
    #     "However, you can paginate manually by sorting the search
    #     results by their creation time and then modifying each
    #     subsequent query to exclude data you have already seen." -
    #     see sort_by field at
    #     https://developers.asana.com/reference/searchtasksforworkspace
    # 
    # _@param_ `api_params`
    # 
    # _@param_ `workspace_gid`
    # 
    # _@param_ `url`
    # 
    # _@param_ `extra_fields`
    # 
    # _@param_ `fetch_all` — Ensure all results are provided by manually paginating
    sig { params(api_params: T::Hash[Symbol, Object], workspace_gid: String, extra_fields: T::Array[String]).returns(T::Enumerable[Asana::Resources::Task]) }
    def iterated_raw_task_search(api_params, workspace_gid:, extra_fields:); end

    # _@param_ `extra_fields`
    sig { params(extra_fields: T::Array[String]).returns(T::Hash[Symbol, Object]) }
    def calculate_api_options(extra_fields); end

    sig { void }
    def self.run; end

    sig { returns(::Logger) }
    def logger; end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def error(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def warn(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def info(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def debug(message = nil, &block); end

    # _@param_ `message`
    sig { params(message: T.nilable(String), block: T.untyped).void }
    def finer(message = nil, &block); end

    # @sg-ignore
    sig { returns(Symbol) }
    def log_level; end

    sig { returns(Checkoff::TaskSelectors) }
    attr_reader :task_selectors

    sig { returns(Checkoff::Projects) }
    attr_reader :projects

    sig { returns(Checkoff::Workspaces) }
    attr_reader :workspaces

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    sig { returns(Asana::Client) }
    attr_reader :client
  end

  # Filter lists of tasks using declarative selectors.
  class TaskSelectors
    MINUTE = T.let(60, T.untyped)
    HOUR = T.let(MINUTE * 60, T.untyped)
    DAY = T.let(24 * HOUR, T.untyped)
    REALLY_LONG_CACHE_TIME = T.let(HOUR * 1, T.untyped)
    LONG_CACHE_TIME = T.let(MINUTE * 15, T.untyped)
    SHORT_CACHE_TIME = T.let(MINUTE, T.untyped)

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    # sord omit - no YARD type given for "custom_fields:", using untyped
    # @sg-ignore
    # 
    # _@param_ `config`
    # 
    # _@param_ `client`
    # 
    # _@param_ `tasks`
    # 
    # _@param_ `timelines`
    sig do
      params(
        config: T::Hash[T.untyped, T.untyped],
        client: Asana::Client,
        tasks: Checkoff::Tasks,
        timelines: Checkoff::Timelines,
        custom_fields: T.untyped
      ).void
    end
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana), client: Checkoff::Clients.new(config: config).client, tasks: Checkoff::Tasks.new(config: config,
                                              client: client), timelines: Checkoff::Timelines.new(config: config,
                                                      client: client), custom_fields: Checkoff::CustomFields.new(config: config,
                                                             client: client)); end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # _@param_ `task`
    # 
    # _@param_ `task_selector` — Filter based on task details.  Examples: [:tag, 'foo'] [:not, [:tag, 'foo']] [:tag, 'foo']
    sig { params(task: Asana::Resources::Task, task_selector: T::Array[[Symbol, T::Array[T.untyped]]]).returns(T::Boolean) }
    def filter_via_task_selector(task, task_selector); end

    # @sg-ignore
    sig { returns(String) }
    def self.project_name; end

    # @sg-ignore
    sig { returns(String) }
    def self.workspace_name; end

    sig { returns(T::Array[T.untyped]) }
    def self.task_selector; end

    sig { void }
    def self.run; end

    sig { returns(Checkoff::Tasks) }
    attr_reader :tasks

    sig { returns(Checkoff::Timelines) }
    attr_reader :timelines

    sig { returns(Checkoff::CustomFields) }
    attr_reader :custom_fields
  end

  # Filter lists of projects using declarative selectors.
  class ProjectSelectors
    MINUTE = T.let(60, T.untyped)
    HOUR = T.let(MINUTE * 60, T.untyped)
    DAY = T.let(24 * HOUR, T.untyped)
    REALLY_LONG_CACHE_TIME = T.let(HOUR * 1, T.untyped)
    LONG_CACHE_TIME = T.let(MINUTE * 15, T.untyped)
    SHORT_CACHE_TIME = T.let(MINUTE, T.untyped)

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    # _@param_ `config`
    # 
    # _@param_ `workspaces`
    # 
    # _@param_ `projects`
    # 
    # _@param_ `custom_fields`
    # 
    # _@param_ `portfolios`
    # 
    # _@param_ `clients`
    # 
    # _@param_ `client`
    sig do
      params(
        config: T::Hash[Symbol, Object],
        workspaces: Checkoff::Workspaces,
        projects: Checkoff::Projects,
        custom_fields: Checkoff::CustomFields,
        portfolios: Checkoff::Portfolios,
        clients: Checkoff::Clients,
        client: Asana::Client
      ).void
    end
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana), workspaces: Checkoff::Workspaces.new(config: config), projects: Checkoff::Projects.new(config: config), custom_fields: Checkoff::CustomFields.new(config: config), portfolios: Checkoff::Portfolios.new(config: config), clients: Checkoff::Clients.new(config: config), client: clients.client); end

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # _@param_ `project`
    # 
    # _@param_ `project_selector` — Filter based on project details.  Examples: [:tag, 'foo'] [:not, [:tag, 'foo']] [:tag, 'foo']
    sig { params(project: Asana::Resources::Project, project_selector: T::Array[[Symbol, T::Array[T.untyped]]]).returns(T::Boolean) }
    def filter_via_project_selector(project, project_selector); end

    sig { void }
    def self.run; end

    sig { returns(Checkoff::Workspaces) }
    attr_reader :workspaces

    sig { returns(Checkoff::Projects) }
    attr_reader :projects

    sig { returns(Checkoff::CustomFields) }
    attr_reader :custom_fields

    sig { returns(Checkoff::Portfolios) }
    attr_reader :portfolios

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    sig { returns(Asana::Client) }
    attr_reader :client
  end

  # Filter lists of sections using declarative selectors.
  class SectionSelectors
    MINUTE = T.let(60, T.untyped)
    HOUR = T.let(MINUTE * 60, T.untyped)
    DAY = T.let(24 * HOUR, T.untyped)
    REALLY_LONG_CACHE_TIME = T.let(HOUR * 1, T.untyped)
    LONG_CACHE_TIME = T.let(MINUTE * 15, T.untyped)
    SHORT_CACHE_TIME = T.let(MINUTE, T.untyped)

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    # _@param_ `config`
    # 
    # _@param_ `workspaces`
    # 
    # _@param_ `sections`
    # 
    # _@param_ `custom_fields`
    # 
    # _@param_ `clients`
    # 
    # _@param_ `client`
    sig do
      params(
        config: T::Hash[Symbol, Object],
        workspaces: Checkoff::Workspaces,
        sections: Checkoff::Sections,
        custom_fields: Checkoff::CustomFields,
        clients: Checkoff::Clients,
        client: Asana::Client
      ).void
    end
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana), workspaces: Checkoff::Workspaces.new(config: config), sections: Checkoff::Sections.new(config: config), custom_fields: Checkoff::CustomFields.new(config: config), clients: Checkoff::Clients.new(config: config), client: clients.client); end

    # sord warn - Asana::Resources::Section wasn't able to be resolved to a constant in this project
    # _@param_ `section`
    # 
    # _@param_ `section_selector` — Filter based on section details.  Examples: [:tag, 'foo'] [:not, [:tag, 'foo']] [:tag, 'foo']
    sig { params(section: Asana::Resources::Section, section_selector: T::Array[[Symbol, T::Array[T.untyped]]]).returns(T::Boolean) }
    def filter_via_section_selector(section, section_selector); end

    sig { void }
    def self.run; end

    sig { returns(Checkoff::Workspaces) }
    attr_reader :workspaces

    sig { returns(Checkoff::Sections) }
    attr_reader :sections

    sig { returns(Checkoff::CustomFields) }
    attr_reader :custom_fields

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    sig { returns(Asana::Client) }
    attr_reader :client
  end

  module Internal
    # Builds on the standard API representation of an Asana task with some
    # convenience keys.
    class TaskHashes
      # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
      # _@param_ `task`
      sig { params(task: Asana::Resources::Task).returns(T::Hash[T.untyped, T.untyped]) }
      def task_to_h(task); end

      # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
      # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
      # _@param_ `task_data`
      # 
      # _@param_ `client`
      sig { params(task_data: T::Hash[T.untyped, T.untyped], client: Asana::Client).returns(Asana::Resources::Task) }
      def h_to_task(task_data, client:); end

      # _@param_ `task_hash`
      sig { params(task_hash: T::Hash[T.untyped, T.untyped]).void }
      def unwrap_custom_fields(task_hash); end

      # sord warn - Invalid hash, must have exactly two types: "Hash<String, Hash, Array>".
      # _@param_ `task_hash`
      # 
      # _@param_ `memberships`
      sig { params(task_hash: T.untyped, memberships: T::Array[T::Hash[T.untyped, T.untyped]]).void }
      def add_user_task_list(task_hash, memberships); end

      # _@param_ `task_hash`
      # 
      # _@param_ `resource`
      # 
      # _@param_ `memberships`
      # 
      # _@param_ `key`
      sig do
        params(
          task_hash: T::Hash[T.untyped, T.untyped],
          memberships: T::Array[T::Hash[T.untyped, T.untyped]],
          resource: String,
          key: String
        ).void
      end
      def unwrap_memberships(task_hash, memberships, resource, key); end

      # _@param_ `task_hash`
      sig { params(task_hash: T::Hash[T.untyped, T.untyped]).void }
      def unwrap_all_memberships(task_hash); end
    end

    # Utility methods for working with task dates and times
    class TaskTiming
      # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
      # _@param_ `time_class`
      # 
      # _@param_ `date_class`
      # 
      # _@param_ `client`
      # 
      # _@param_ `custom_fields`
      sig do
        params(
          time_class: T.class_of(Time),
          date_class: T.class_of(Date),
          client: Asana::Client,
          custom_fields: Checkoff::CustomFields
        ).void
      end
      def initialize(time_class: Time, date_class: Date, client: Checkoff::Clients.new.client, custom_fields: Checkoff::CustomFields.new(client: client)); end

      # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
      # _@param_ `task`
      sig { params(task: Asana::Resources::Task).returns(T.nilable(Time)) }
      def start_time(task); end

      # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
      # _@param_ `task`
      sig { params(task: Asana::Resources::Task).returns(T.nilable(Time)) }
      def due_time(task); end

      # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
      # @sg-ignore
      # 
      # _@param_ `task`
      # 
      # _@param_ `field_name`
      sig { params(task: Asana::Resources::Task).returns(T.nilable(T.any(Date, Time))) }
      def start_date_or_time(task); end

      # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
      # @sg-ignore
      # 
      # _@param_ `task`
      # 
      # _@param_ `field_name`
      sig { params(task: Asana::Resources::Task).returns(T.nilable(T.any(Date, Time))) }
      def due_date_or_time(task); end

      # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
      # _@param_ `task`
      sig { params(task: Asana::Resources::Task).returns(T.nilable(Time)) }
      def modified_time(task); end

      # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
      # _@param_ `task`
      # 
      # _@param_ `custom_field_name`
      sig { params(task: Asana::Resources::Task, custom_field_name: String).returns(T.nilable(T.any(Time, Date))) }
      def custom_field(task, custom_field_name); end

      # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
      # @sg-ignore
      # 
      # _@param_ `task`
      # 
      # _@param_ `field_name`
      sig { params(task: Asana::Resources::Task, field_name: T.any(Symbol, T::Array[T.untyped])).returns(T.nilable(T.any(Date, Time))) }
      def date_or_time_field_by_name(task, field_name); end
    end

    # Manage thread lock variables in a block
    class ThreadLocal
      # @sg-ignore
      # 
      # _@param_ `name`
      # 
      # _@param_ `value`
      sig { params(name: Symbol, value: T.any(Object, T::Boolean), block: T.untyped).returns(T.any(Object, T::Boolean)) }
      def with_thread_local_variable(name, value, &block); end
    end

    # Use the provided config from a YAML file, and fall back to env
    # variable if it's not populated for a key'
    class EnvFallbackConfigLoader
      # _@param_ `config`
      # 
      # _@param_ `sym`
      # 
      # _@param_ `yaml_filename`
      sig { params(config: T::Hash[Symbol, Object], sym: Symbol, yaml_filename: String).void }
      def initialize(config, sym, yaml_filename); end

      # _@param_ `key`
      sig { params(key: Symbol).returns(Object) }
      def [](key); end

      # _@param_ `key`
      sig { params(key: Symbol).returns(Object) }
      def fetch(key); end

      # _@param_ `key`
      sig { params(key: Symbol).returns(String) }
      def envvar_name(key); end
    end

    # Load configuration file
    class ConfigLoader
      # sord omit - no YARD type given for "sym", using untyped
      # @sg-ignore
      sig { params(sym: T.untyped).returns(T::Hash[Symbol, Object]) }
      def self.load(sym); end

      # sord warn - "[String" does not appear to be a type
      # sord warn - "Symbol]" does not appear to be a type
      # sord warn - Invalid hash, must have exactly two types: "Hash<[String, Symbol], Object>".
      # _@param_ `sym`
      sig { params(sym: Symbol).returns(T.untyped) }
      def self.load_yaml_file(sym); end

      # _@param_ `sym`
      sig { params(sym: Symbol).returns(String) }
      def self.yaml_filename(sym); end
    end

    # Builds on the standard API representation of an Asana project with some
    # convenience keys.
    class ProjectHashes
      # _@param_ `_deps`
      sig { params(_deps: T::Hash[T.untyped, T.untyped]).void }
      def initialize(_deps = {}); end

      # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
      # _@param_ `project_obj`
      # 
      # _@param_ `project`
      sig { params(project_obj: Asana::Resources::Project, project: T.any(String, Symbol)).returns(T::Hash[T.untyped, T.untyped]) }
      def project_to_h(project_obj, project: :not_specified); end

      # _@param_ `project_hash`
      sig { params(project_hash: T::Hash[T.untyped, T.untyped]).void }
      def unwrap_custom_fields(project_hash); end
    end

    # Utility methods for working with project dates and times
    class ProjectTiming
      # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
      # _@param_ `time_class`
      # 
      # _@param_ `date_class`
      # 
      # _@param_ `client`
      # 
      # _@param_ `custom_fields`
      sig do
        params(
          time_class: T.class_of(Time),
          date_class: T.class_of(Date),
          client: Asana::Client,
          custom_fields: Checkoff::CustomFields
        ).void
      end
      def initialize(time_class: Time, date_class: Date, client: Checkoff::Clients.new.client, custom_fields: Checkoff::CustomFields.new(client: client)); end

      # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
      # @sg-ignore
      # 
      # _@param_ `project`
      # 
      # _@param_ `field_name`
      sig { params(project: Asana::Resources::Project).returns(T.nilable(Date)) }
      def start_date(project); end

      # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
      # @sg-ignore
      # 
      # _@param_ `project`
      # 
      # _@param_ `field_name`
      sig { params(project: Asana::Resources::Project).returns(T.nilable(Date)) }
      def due_date(project); end

      # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
      # _@param_ `project`
      # 
      # _@param_ `custom_field_name`
      sig { params(project: Asana::Resources::Project, custom_field_name: String).returns(T.nilable(T.any(Time, Date))) }
      def custom_field(project, custom_field_name); end

      # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
      # @sg-ignore
      # 
      # _@param_ `project`
      # 
      # _@param_ `field_name`
      sig { params(project: Asana::Resources::Project, field_name: T.any(Symbol, T::Array[T.untyped])).returns(T.nilable(T.any(Date, Time))) }
      def date_or_time_field_by_name(project, field_name); end
    end

    module SearchUrl
      # Parse Asana search URLs into parameters suitable to pass into
      # the /workspaces/{workspace_gid}/tasks/search endpoint
      class Parser
        # _@param_ `_deps`
        sig { params(_deps: T::Hash[T.untyped, T.untyped]).void }
        def initialize(_deps = {}); end

        # _@param_ `url`
        sig { params(url: String).returns([T::Hash[String, String], T::Hash[String, String]]) }
        def convert_params(url); end

        # sord warn - "[Symbol" does not appear to be a type
        # sord warn - "Array]" does not appear to be a type
        # _@param_ `date_url_params`
        sig { params(date_url_params: T::Hash[String, T::Array[String]]).returns([T::Hash[String, String], T::Array[T.any(T.untyped, T.untyped)]]) }
        def convert_date_params(date_url_params); end

        # _@param_ `simple_url_params`
        sig { params(simple_url_params: T::Hash[String, T::Array[String]]).returns(T::Hash[String, String]) }
        def convert_simple_params(simple_url_params); end

        # sord warn - "[Symbol" does not appear to be a type
        # sord warn - "Array]" does not appear to be a type
        # _@param_ `custom_field_params`
        sig { params(custom_field_params: T::Hash[String, T::Array[String]]).returns([T::Hash[String, String], T::Array[T.any(T.untyped, T.untyped)]]) }
        def convert_custom_field_params(custom_field_params); end

        # _@param_ `url_params`
        sig { params(url_params: T::Hash[String, String]).returns([T::Hash[String, String], T::Hash[String, String], T::Hash[String, String]]) }
        def partition_url_params(url_params); end
      end

      # Merge task selectors and search API arguments
      class ResultsMerger
        # sord warn - "[Hash<String, String>]" does not appear to be a type
        # _@param_ `args`
        # 
        # _@return_ — Hash<String, String>
        sig { params(args: T::Array[T.untyped]).returns(T::Hash[String, String]) }
        def self.merge_args(*args); end

        # sord warn - "[Symbol" does not appear to be a type
        # sord warn - "Array]" does not appear to be a type
        # sord warn - "[Symbol" does not appear to be a type
        # sord warn - "Array]" does not appear to be a type
        # _@param_ `task_selectors`
        sig { params(task_selectors: T::Array[T::Array[T.any(T.untyped, T.untyped)]]).returns(T::Array[T.any(T.untyped, T.untyped)]) }
        def self.merge_task_selectors(*task_selectors); end
      end

      # https://developers.asana.com/docs/search-tasks-in-a-workspace
      module CustomFieldVariant
        # base class for handling different custom_field_#{gid}.variant params
        class CustomFieldVariant
          # _@param_ `gid`
          # 
          # _@param_ `remaining_params`
          sig { params(gid: String, remaining_params: T::Hash[T.untyped, T.untyped]).void }
          def initialize(gid, remaining_params); end

          sig { void }
          def ensure_no_remaining_params!; end

          # _@param_ `param_name`
          sig { params(param_name: String).returns(String) }
          def fetch_solo_param(param_name); end

          sig { returns(String) }
          attr_reader :gid

          sig { returns(T::Hash[T.untyped, T.untyped]) }
          attr_reader :remaining_params
        end

        # custom_field_#{gid}.variant = 'less_than'
        class LessThan < Checkoff::Internal::SearchUrl::CustomFieldVariant::CustomFieldVariant
          sig { returns(T::Array[[T::Hash[T.untyped, T.untyped], T::Array[T.untyped]]]) }
          def convert; end
        end

        # custom_field_#{gid}.variant = 'greater_than'
        class GreaterThan < Checkoff::Internal::SearchUrl::CustomFieldVariant::CustomFieldVariant
          sig { returns(T::Array[[T::Hash[T.untyped, T.untyped], T::Array[T.untyped]]]) }
          def convert; end
        end

        # custom_field_#{gid}.variant = 'equals'
        class Equals < Checkoff::Internal::SearchUrl::CustomFieldVariant::CustomFieldVariant
          sig { returns(T::Array[[T::Hash[T.untyped, T.untyped], T::Array[T.untyped]]]) }
          def convert; end
        end

        # This is used in the UI for select fields
        # 
        # custom_field_#{gid}.variant = 'is_not'
        class IsNot < Checkoff::Internal::SearchUrl::CustomFieldVariant::CustomFieldVariant
          sig { returns(T::Array[[T::Hash[T.untyped, T.untyped], T::Array[T.untyped]]]) }
          def convert; end
        end

        # This is used in the UI for multi-select fields
        # 
        # custom_field_#{gid}.variant = 'doesnt_contain_any'
        class DoesntContainAny < Checkoff::Internal::SearchUrl::CustomFieldVariant::CustomFieldVariant
          sig { returns(T::Array[[T::Hash[T.untyped, T.untyped], T::Array[T.untyped]]]) }
          def convert; end
        end

        # This is used in the UI for multi-select fields
        # 
        # custom_field_#{gid}.variant = 'contains_any'
        class ContainsAny < Checkoff::Internal::SearchUrl::CustomFieldVariant::CustomFieldVariant
          sig { returns(T::Array[[T::Hash[T.untyped, T.untyped], T::Array[T.untyped]]]) }
          def convert; end
        end

        # This is used in the UI for multi-select fields
        # 
        # custom_field_#{gid}.variant = 'contains_all'
        class ContainsAll < Checkoff::Internal::SearchUrl::CustomFieldVariant::CustomFieldVariant
          sig { returns(T::Array[[T::Hash[T.untyped, T.untyped], T::Array[T.untyped]]]) }
          def convert; end
        end

        # custom_field_#{gid}.variant = 'no_value'
        class NoValue < Checkoff::Internal::SearchUrl::CustomFieldVariant::CustomFieldVariant
          sig { returns(T::Array[[T::Hash[T.untyped, T.untyped], T::Array[T.untyped]]]) }
          def convert; end
        end

        # custom_field_#{gid}.variant = 'any_value'
        # 
        # Not used for multi-select fields
        class AnyValue < Checkoff::Internal::SearchUrl::CustomFieldVariant::CustomFieldVariant
          sig { returns(T::Array[[T::Hash[T.untyped, T.untyped], T::Array[T.untyped]]]) }
          def convert; end
        end

        # custom_field_#{gid}.variant = 'is'
        class Is < Checkoff::Internal::SearchUrl::CustomFieldVariant::CustomFieldVariant
          sig { returns(T::Array[[T::Hash[T.untyped, T.untyped], T::Array[T.untyped]]]) }
          def convert; end
        end
      end

      # Convert date parameters - ones where the param name itself
      # doesn't encode any parameters'
      class DateParamConverter
        API_PREFIX = T.let({
  'due_date' => 'due_on',
  'start_date' => 'start_on',
  'completion_date' => 'completed_on',
}.freeze, T.untyped)

        # _@param_ `date_url_params` — the simple params
        sig { params(date_url_params: T::Hash[String, T::Array[String]]).void }
        def initialize(date_url_params:); end

        # sord warn - "[Symbol" does not appear to be a type
        # sord warn - "Array]" does not appear to be a type
        # @sg-ignore
        sig { returns([T::Hash[String, String], T::Array[T.any(T.untyped, T.untyped)]]) }
        def convert; end

        # sord warn - "[Symbol" does not appear to be a type
        # sord warn - "Array]" does not appear to be a type
        # @sg-ignore
        # 
        # _@param_ `prefix`
        sig { params(prefix: String).returns([T::Hash[String, String], T::Array[T.any(T.untyped, T.untyped)]]) }
        def convert_for_prefix(prefix); end

        # sord warn - "[Symbol" does not appear to be a type
        # sord warn - "Array]" does not appear to be a type
        # _@param_ `prefix`
        # 
        # _@return_ — See https://developers.asana.com/docs/search-tasks-in-a-workspace
        sig { params(prefix: String).returns([T::Hash[String, String], T::Array[T.any(T.untyped, T.untyped)]]) }
        def handle_through_next(prefix); end

        # sord warn - "[Symbol" does not appear to be a type
        # sord warn - "Array]" does not appear to be a type
        # _@param_ `prefix`
        # 
        # _@return_ — See https://developers.asana.com/docs/search-tasks-in-a-workspace
        sig { params(prefix: String).returns([T::Hash[String, String], T::Array[T.any(T.untyped, T.untyped)]]) }
        def handle_between(prefix); end

        # sord warn - "[Symbol" does not appear to be a type
        # sord warn - "Array]" does not appear to be a type
        # _@param_ `prefix`
        # 
        # _@return_ — See https://developers.asana.com/docs/search-tasks-in-a-workspace
        sig { params(prefix: String).returns([T::Hash[String, String], T::Array[T.any(T.untyped, T.untyped)]]) }
        def handle_within_last(prefix); end

        # sord warn - "[Symbol" does not appear to be a type
        # sord warn - "Array]" does not appear to be a type
        # _@param_ `prefix`
        # 
        # _@return_ — See https://developers.asana.com/docs/search-tasks-in-a-workspace
        sig { params(prefix: String).returns([T::Hash[String, String], T::Array[T.any(T.untyped, T.untyped)]]) }
        def handle_within_next(prefix); end

        # _@param_ `param_key`
        sig { params(param_key: String).returns(String) }
        def get_single_param(param_key); end

        # _@param_ `prefix`
        sig { params(prefix: String).void }
        def validate_unit_not_provided!(prefix); end

        # _@param_ `prefix`
        sig { params(prefix: String).void }
        def validate_unit_is_day!(prefix); end

        sig { returns(T::Hash[String, T::Array[String]]) }
        attr_reader :date_url_params
      end

      # See
      # https://developers.asana.com/docs/search-tasks-in-a-workspace
      # for the return value of 'convert' here:
      module SimpleParam
        # base class for handling different types of search url params
        class SimpleParam
          # _@param_ `key` — the name of the search url param
          # 
          # _@param_ `values` — the values of the search url param
          sig { params(key: String, values: T::Array[String]).void }
          def initialize(key:, values:); end

          # @sg-ignore
          # 
          # _@return_ — the single value of the search url param
          sig { returns(String) }
          def single_value; end

          # Inputs:
          #   123_column_456 means "abc" project, "def" section
          #   123 means "abc" project
          #   123~456 means "abc" and "def" projects
          # 
          # _@param_ `projects`
          # 
          # _@param_ `sections`
          sig { params(projects: T::Array[String], sections: T::Array[String]).void }
          def parse_projects_and_sections(projects, sections); end

          # _@param_ `verb`
          sig { params(verb: String).returns(T::Array[String]) }
          def convert_from_projects_and_sections(verb); end

          sig { returns(String) }
          attr_reader :key

          sig { returns(T::Array[String]) }
          attr_reader :values
        end

        # Handle 'portfolios.ids' search url param
        class PortfoliosIds < Checkoff::Internal::SearchUrl::SimpleParam::SimpleParam
          sig { returns(T::Array[String]) }
          def convert; end
        end

        # Handle 'any_projects.ids' search url param
        class AnyProjectsIds < Checkoff::Internal::SearchUrl::SimpleParam::SimpleParam
          sig { returns(T::Array[String]) }
          def convert; end
        end

        # Handle 'not_projects.ids' search url param
        class NotProjectsIds < Checkoff::Internal::SearchUrl::SimpleParam::SimpleParam
          sig { returns(T::Array[String]) }
          def convert; end
        end

        # Handle 'completion' search url param
        class Completion < Checkoff::Internal::SearchUrl::SimpleParam::SimpleParam
          sig { returns(T::Array[String]) }
          def convert; end
        end

        # Handle 'not_tags.ids' search url param
        class NotTagsIds < Checkoff::Internal::SearchUrl::SimpleParam::SimpleParam
          sig { returns(T::Array[String]) }
          def convert; end
        end

        # handle 'subtask' search url param
        class Subtask < Checkoff::Internal::SearchUrl::SimpleParam::SimpleParam
          # sord warn - "[String" does not appear to be a type
          # sord warn - "Boolean]" does not appear to be a type
          sig { returns(T::Array[T.any(T.untyped, T.untyped)]) }
          def convert; end
        end

        # Handle 'any_tags.ids' search url param
        class AnyTagsIds < Checkoff::Internal::SearchUrl::SimpleParam::SimpleParam
          sig { returns(T::Array[String]) }
          def convert; end
        end

        # Handle 'sort' search url param
        class Sort < Checkoff::Internal::SearchUrl::SimpleParam::SimpleParam
          sig { returns(T::Array[String]) }
          def convert; end
        end

        # Handle 'milestone' search url param
        class Milestone < Checkoff::Internal::SearchUrl::SimpleParam::SimpleParam
          sig { returns(T::Array[String]) }
          def convert; end
        end

        # Handle 'searched_type' search url param
        class SearchedType < Checkoff::Internal::SearchUrl::SimpleParam::SimpleParam
          sig { returns(T::Array[String]) }
          def convert; end
        end
      end

      # Convert simple parameters - ones where the param name itself
      # doesn't encode any parameters'
      class SimpleParamConverter
        ARGS = T.let({
  'portfolios.ids' => SimpleParam::PortfoliosIds,
  'any_projects.ids' => SimpleParam::AnyProjectsIds,
  'not_projects.ids' => SimpleParam::NotProjectsIds,
  'completion' => SimpleParam::Completion,
  'not_tags.ids' => SimpleParam::NotTagsIds,
  'any_tags.ids' => SimpleParam::AnyTagsIds,
  'subtask' => SimpleParam::Subtask,
  'sort' => SimpleParam::Sort,
  'milestone' => SimpleParam::Milestone,
  'searched_type' => SimpleParam::SearchedType,
}.freeze, T.untyped)

        # _@param_ `simple_url_params` — the simple params
        sig { params(simple_url_params: T::Hash[String, T::Array[String]]).void }
        def initialize(simple_url_params:); end

        # _@return_ — the converted params
        sig { returns(T::Hash[String, String]) }
        def convert; end

        # https://developers.asana.com/docs/search-tasks-in-a-workspace
        # @sg-ignore
        # 
        # _@param_ `key` — the name of the search url param
        # 
        # _@param_ `values` — the values of the search url param
        # 
        # _@return_ — the converted params
        sig { params(key: String, values: T::Array[String]).returns(T::Hash[String, String]) }
        def convert_arg(key, values); end

        sig { returns(T::Hash[String, T::Array[String]]) }
        attr_reader :simple_url_params
      end

      # Convert custom field parameters from an Asana search URL into
      # API search arguments and Checkoff task selectors
      class CustomFieldParamConverter
        VARIANTS = T.let({
  'is' => CustomFieldVariant::Is,
  'no_value' => CustomFieldVariant::NoValue,
  'any_value' => CustomFieldVariant::AnyValue,
  'is_not' => CustomFieldVariant::IsNot,
  'less_than' => CustomFieldVariant::LessThan,
  'greater_than' => CustomFieldVariant::GreaterThan,
  'equals' => CustomFieldVariant::Equals,
  'doesnt_contain_any' => CustomFieldVariant::DoesntContainAny,
  'contains_any' => CustomFieldVariant::ContainsAny,
  'contains_all' => CustomFieldVariant::ContainsAll,
}.freeze, T.untyped)

        # _@param_ `custom_field_params`
        sig { params(custom_field_params: T::Hash[String, T::Array[String]]).void }
        def initialize(custom_field_params:); end

        # sord warn - "[Symbol" does not appear to be a type
        # sord warn - "Array]" does not appear to be a type
        sig { returns([T::Hash[String, String], T::Array[T.any(T.untyped, T.untyped)]]) }
        def convert; end

        # @sg-ignore
        sig { returns(T::Hash[String, T::Hash[T.untyped, T.untyped]]) }
        def by_custom_field; end

        # sord warn - "[Symbol" does not appear to be a type
        # sord warn - "Array]" does not appear to be a type
        # @sg-ignore
        # 
        # _@param_ `gid`
        # 
        # _@param_ `single_custom_field_params`
        sig { params(gid: String, single_custom_field_params: T::Hash[String, T::Array[String]]).returns([T::Hash[String, String], T::Array[T.any(T.untyped, T.untyped)]]) }
        def convert_single_custom_field_params(gid, single_custom_field_params); end

        # _@param_ `key`
        sig { params(key: String).returns(String) }
        def gid_from_custom_field_key(key); end

        sig { returns(T::Hash[String, T::Array[String]]) }
        attr_reader :custom_field_params
      end
    end

    # Uses an enhanced version of Asana event filter configuration
    # 
    # See https://developers.asana.com/reference/createwebhook | body
    # params | data | filters | add object for a general description of the scheme.
    # 
    # Additional supported filter keys:
    # 
    # * 'checkoff:parent.gid' - requires that the 'gid' key in the 'parent' object
    #   match the given value
    class AsanaEventFilter
      include Logging

      # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
      # _@param_ `filters` — The filters to match against
      # 
      # _@param_ `clients`
      # 
      # _@param_ `tasks`
      # 
      # _@param_ `client`
      sig do
        params(
          filters: T.nilable(T::Array[T::Hash[T.untyped, T.untyped]]),
          clients: Checkoff::Clients,
          tasks: Checkoff::Tasks,
          client: Asana::Client
        ).void
      end
      def initialize(filters:, clients: Checkoff::Clients.new, tasks: Checkoff::Tasks.new, client: clients.client); end

      # _@param_ `asana_event` — The event that Asana sent
      sig { params(asana_event: T::Hash[T.untyped, T.untyped]).returns(T::Boolean) }
      def matches?(asana_event); end

      # @sg-ignore
      # 
      # _@param_ `filter`
      # 
      # _@param_ `asana_event`
      # 
      # _@param_ `failures`
      sig { params(filter: T::Hash[T.untyped, T.untyped], asana_event: T::Hash[T.untyped, T.untyped], failures: T::Array[String]).returns(T::Boolean) }
      def filter_matches_asana_event?(filter, asana_event, failures); end

      # @sg-ignore
      # 
      # _@param_ `key`
      # 
      # _@param_ `value`
      # 
      # _@param_ `asana_event`
      sig { params(key: String, value: T.any(String, T::Array[String]), asana_event: T::Hash[T.untyped, T.untyped]).returns(T::Boolean) }
      def asana_event_matches_filter_item?(key, value, asana_event); end

      # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
      # _@param_ `key`
      # 
      # _@param_ `asana_event`
      # 
      # _@param_ `fields`
      sig { params(key: String, asana_event: T::Hash[T.untyped, T.untyped], fields: T::Array[String]).returns(T.nilable(Asana::Resources::Task)) }
      def uncached_fetch_task(key, asana_event, fields); end

      sig { returns(::Logger) }
      def logger; end

      # _@param_ `message`
      sig { params(message: T.nilable(String), block: T.untyped).void }
      def error(message = nil, &block); end

      # _@param_ `message`
      sig { params(message: T.nilable(String), block: T.untyped).void }
      def warn(message = nil, &block); end

      # _@param_ `message`
      sig { params(message: T.nilable(String), block: T.untyped).void }
      def info(message = nil, &block); end

      # _@param_ `message`
      sig { params(message: T.nilable(String), block: T.untyped).void }
      def debug(message = nil, &block); end

      # _@param_ `message`
      sig { params(message: T.nilable(String), block: T.untyped).void }
      def finer(message = nil, &block); end

      # @sg-ignore
      sig { returns(Symbol) }
      def log_level; end
    end

    # Add useful info (like resource task names) into an Asana
    # event/event filters/webhook subscription for human consumption
    class AsanaEventEnrichment
      include Logging

      # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
      # _@param_ `config`
      # 
      # _@param_ `workspaces`
      # 
      # _@param_ `tasks`
      # 
      # _@param_ `sections`
      # 
      # _@param_ `projects`
      # 
      # _@param_ `resources`
      # 
      # _@param_ `clients`
      # 
      # _@param_ `client`
      # 
      # _@param_ `asana_event_enrichment`
      sig do
        params(
          config: T::Hash[T.untyped, T.untyped],
          workspaces: Checkoff::Workspaces,
          tasks: Checkoff::Tasks,
          sections: Checkoff::Sections,
          projects: Checkoff::Projects,
          resources: Checkoff::Resources,
          clients: Checkoff::Clients,
          client: Asana::Client
        ).void
      end
      def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana), workspaces: Checkoff::Workspaces.new(config: config), tasks: Checkoff::Tasks.new(config: config), sections: Checkoff::Sections.new(config: config), projects: Checkoff::Projects.new(config: config), resources: Checkoff::Resources.new(config: config), clients: Checkoff::Clients.new(config: config), client: clients.client); end

      # Add useful info (like resource task names) into an event for
      # human consumption
      # 
      # _@param_ `asana_event`
      sig { params(asana_event: T::Hash[T.untyped, T.untyped]).returns(T::Hash[T.untyped, T.untyped]) }
      def enrich_event(asana_event); end

      # sord warn - "[String" does not appear to be a type
      # sord warn - "Array<String>]" does not appear to be a type
      # sord warn - Invalid hash, must have exactly two types: "Hash<String,[String,Array<String>]>".
      # sord warn - "[String" does not appear to be a type
      # sord warn - "Array<String>]" does not appear to be a type
      # sord warn - Invalid hash, must have exactly two types: "Hash<String,[String,Array<String>]>".
      # _@param_ `filter`
      sig { params(filter: T.untyped).returns(T.untyped) }
      def enrich_filter(filter); end

      # _@param_ `webhook_subscription` — Hash of the request made to webhook POST endpoint - https://app.asana.com/api/1.0/webhooks https://developers.asana.com/reference/createwebhook
      sig { params(webhook_subscription: T::Hash[T.untyped, T.untyped]).void }
      def enrich_webhook_subscription!(webhook_subscription); end

      # sord warn - "[String" does not appear to be a type
      # sord warn - "nil]" does not appear to be a type
      # sord warn - "[String" does not appear to be a type
      # sord warn - "nil]" does not appear to be a type
      # Attempt to look up a GID in situations where we don't have a
      # resource type provided, and returns the name of the resource.
      # 
      # _@param_ `gid`
      # 
      # _@param_ `resource_type`
      sig { params(gid: String, resource_type: T.nilable(String)).returns(T::Array[[T.untyped, T.untyped, T.untyped, T.untyped]]) }
      def enrich_gid(gid, resource_type: nil); end

      # _@param_ `filter`
      sig { params(filter: T::Hash[String, String]).returns(T.nilable(String)) }
      def enrich_filter_parent_gid!(filter); end

      # _@param_ `filter`
      sig { params(filter: T::Hash[String, String]).void }
      def enrich_filter_resource!(filter); end

      # sord warn - "[String" does not appear to be a type
      # sord warn - "Array<String>]" does not appear to be a type
      # sord warn - Invalid hash, must have exactly two types: "Hash{String => [String,Array<String>]}".
      # _@param_ `filter`
      sig { params(filter: T.untyped).void }
      def enrich_filter_section!(filter); end

      # sord warn - "'resource'" does not appear to be a type
      # _@param_ `asana_event`
      sig { params(asana_event: T::Hash[T.untyped, T::Hash[T.untyped, T.untyped]]).void }
      def enrich_event_parent!(asana_event); end

      # sord warn - "'resource'" does not appear to be a type
      # _@param_ `asana_event`
      sig { params(asana_event: T::Hash[T.untyped, T::Hash[T.untyped, T.untyped]]).void }
      def enrich_event_resource!(asana_event); end

      sig { returns(::Logger) }
      def logger; end

      # _@param_ `message`
      sig { params(message: T.nilable(String), block: T.untyped).void }
      def error(message = nil, &block); end

      # _@param_ `message`
      sig { params(message: T.nilable(String), block: T.untyped).void }
      def warn(message = nil, &block); end

      # _@param_ `message`
      sig { params(message: T.nilable(String), block: T.untyped).void }
      def info(message = nil, &block); end

      # _@param_ `message`
      sig { params(message: T.nilable(String), block: T.untyped).void }
      def debug(message = nil, &block); end

      # _@param_ `message`
      sig { params(message: T.nilable(String), block: T.untyped).void }
      def finer(message = nil, &block); end

      # @sg-ignore
      sig { returns(Symbol) }
      def log_level; end

      sig { returns(Checkoff::Projects) }
      attr_reader :projects

      sig { returns(Checkoff::Sections) }
      attr_reader :sections

      sig { returns(Checkoff::Tasks) }
      attr_reader :tasks

      sig { returns(Checkoff::Workspaces) }
      attr_reader :workspaces

      sig { returns(Checkoff::Resources) }
      attr_reader :resources

      # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
      sig { returns(Asana::Client) }
      attr_reader :client
    end
  end

  # Base class to evaluate Asana resource selectors against an Asana resource
  class SelectorEvaluator
    # _@param_ `selector`
    sig { params(selector: T::Array[T.untyped]).returns(T.nilable(T.any(T::Boolean, Object))) }
    def evaluate(selector); end

    sig { returns(T::Hash[T.untyped, T.untyped]) }
    def initializer_kwargs; end

    # sord warn - FunctionEvaluator wasn't able to be resolved to a constant in this project
    # @sg-ignore
    sig { returns(T::Array[T.class_of(Checkoff::SelectorClasses::Task::FunctionEvaluator)]) }
    def function_evaluators; end

    # _@param_ `selector`
    # 
    # _@param_ `evaluator`
    sig { params(selector: T::Array[T.untyped], evaluator: SelectorClasses::FunctionEvaluator).returns(T::Array[T.untyped]) }
    def evaluate_args(selector, evaluator); end

    # _@param_ `selector`
    # 
    # _@param_ `evaluator`
    sig { params(selector: T::Array[T.untyped], evaluator: SelectorClasses::FunctionEvaluator).returns(T.nilable(T.any(T::Boolean, Object))) }
    def try_this_evaluator(selector, evaluator); end

    sig { returns(Asana::Resources::Resource) }
    attr_reader :item
  end

  module SelectorClasses
    module Task
      # :in_a_real_project? function
      class InARealProjectPFunctionEvaluator < Checkoff::SelectorClasses::Task::FunctionEvaluator
        sig { returns(T::Boolean) }
        def matches?; end

        # _@param_ `_index`
        sig { params(_index: Integer).returns(T::Boolean) }
        def evaluate_arg?(_index); end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # @sg-ignore
        # 
        # _@param_ `task`
        sig { params(task: Asana::Resources::Task).returns(T::Boolean) }
        def evaluate(task); end
      end

      # :section_name_starts_with? function
      class SectionNameStartsWithPFunctionEvaluator < Checkoff::SelectorClasses::Task::FunctionEvaluator
        sig { returns(T::Boolean) }
        def matches?; end

        # _@param_ `_index`
        sig { params(_index: Integer).returns(T::Boolean) }
        def evaluate_arg?(_index); end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # @sg-ignore
        # 
        # _@param_ `task`
        # 
        # _@param_ `section_name_prefix`
        sig { params(task: Asana::Resources::Task, section_name_prefix: String).returns(T::Boolean) }
        def evaluate(task, section_name_prefix); end
      end

      # :in_section_named? function
      class InSectionNamedPFunctionEvaluator < Checkoff::SelectorClasses::Task::FunctionEvaluator
        sig { returns(T::Boolean) }
        def matches?; end

        # _@param_ `_index`
        sig { params(_index: Integer).returns(T::Boolean) }
        def evaluate_arg?(_index); end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # @sg-ignore
        # 
        # _@param_ `task`
        # 
        # _@param_ `section_name`
        sig { params(task: Asana::Resources::Task, section_name: String).returns(T::Boolean) }
        def evaluate(task, section_name); end
      end

      # :in_project_named? function
      class InProjectNamedPFunctionEvaluator < Checkoff::SelectorClasses::Task::FunctionEvaluator
        sig { returns(T::Boolean) }
        def matches?; end

        # _@param_ `_index`
        sig { params(_index: Integer).returns(T::Boolean) }
        def evaluate_arg?(_index); end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # @sg-ignore
        # 
        # _@param_ `task`
        # 
        # _@param_ `project_name`
        sig { params(task: Asana::Resources::Task, project_name: String).returns(T::Boolean) }
        def evaluate(task, project_name); end
      end

      # :in_portfolio_more_than_once? function
      class InPortfolioMoreThanOncePFunctionEvaluator < Checkoff::SelectorClasses::Task::FunctionEvaluator
        sig { returns(T::Boolean) }
        def matches?; end

        # _@param_ `_index`
        sig { params(_index: Integer).returns(T::Boolean) }
        def evaluate_arg?(_index); end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # @sg-ignore
        # 
        # _@param_ `task`
        # 
        # _@param_ `portfolio_name`
        sig { params(task: Asana::Resources::Task, portfolio_name: String).returns(T::Boolean) }
        def evaluate(task, portfolio_name); end
      end

      # :tag? function
      class TagPFunctionEvaluator < Checkoff::SelectorClasses::Task::FunctionEvaluator
        sig { returns(T::Boolean) }
        def matches?; end

        # _@param_ `_index`
        sig { params(_index: Integer).returns(T::Boolean) }
        def evaluate_arg?(_index); end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # @sg-ignore
        # 
        # _@param_ `task`
        # 
        # _@param_ `tag_name`
        sig { params(task: Asana::Resources::Task, tag_name: String).returns(T::Boolean) }
        def evaluate(task, tag_name); end
      end

      # :ready? function
      # 
      # See GLOSSARY.md and tasks.rb#task_ready? for more information.
      class ReadyPFunctionEvaluator < Checkoff::SelectorClasses::Task::FunctionEvaluator
        sig { returns(T::Boolean) }
        def matches?; end

        # _@param_ `_index`
        sig { params(_index: Integer).returns(T::Boolean) }
        def evaluate_arg?(_index); end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # rubocop:disable Style/OptionalBooleanParameter
        # 
        # _@param_ `task`
        # 
        # _@param_ `period`
        # 
        # _@param_ `ignore_dependencies`
        sig { params(task: Asana::Resources::Task, period: Symbol, ignore_dependencies: T::Boolean).returns(T::Boolean) }
        def evaluate(task, period = :now_or_before, ignore_dependencies = false); end
      end

      # :in_period? function
      class InPeriodPFunctionEvaluator < Checkoff::SelectorClasses::Task::FunctionEvaluator
        sig { returns(T::Boolean) }
        def matches?; end

        # _@param_ `_index`
        sig { params(_index: Integer).returns(T::Boolean) }
        def evaluate_arg?(_index); end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # _@param_ `task`
        # 
        # _@param_ `field_name` — See Checksoff::Tasks#in_period?
        # 
        # _@param_ `period` — See Checkoff::Timing#in_period?
        sig { params(task: Asana::Resources::Task, field_name: Symbol, period: T.any(Symbol, T::Array[Symbol])).returns(T::Boolean) }
        def evaluate(task, field_name, period); end
      end

      # :unassigned? function
      class UnassignedPFunctionEvaluator < Checkoff::SelectorClasses::Task::FunctionEvaluator
        sig { returns(T::Boolean) }
        def matches?; end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # _@param_ `task`
        sig { params(task: Asana::Resources::Task).returns(T::Boolean) }
        def evaluate(task); end
      end

      # :due_date_set? function
      class DueDateSetPFunctionEvaluator < Checkoff::SelectorClasses::Task::FunctionEvaluator
        FUNCTION_NAME = T.let(:due_date_set?, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # @sg-ignore
        # 
        # _@param_ `task`
        sig { params(task: Asana::Resources::Task).returns(T::Boolean) }
        def evaluate(task); end
      end

      # :last_story_created_less_than_n_days_ago? function
      class LastStoryCreatedLessThanNDaysAgoPFunctionEvaluator < Checkoff::SelectorClasses::Task::FunctionEvaluator
        FUNCTION_NAME = T.let(:last_story_created_less_than_n_days_ago?, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        sig { params(_index: Integer).returns(T::Boolean) }
        def evaluate_arg?(_index); end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # _@param_ `task`
        # 
        # _@param_ `num_days`
        # 
        # _@param_ `excluding_resource_subtypes`
        sig { params(task: Asana::Resources::Task, num_days: Integer, excluding_resource_subtypes: T::Array[String]).returns(T::Boolean) }
        def evaluate(task, num_days, excluding_resource_subtypes); end
      end

      # :estimate_exceeds_duration?
      class EstimateExceedsDurationPFunctionEvaluator < Checkoff::SelectorClasses::Task::FunctionEvaluator
        FUNCTION_NAME = T.let(:estimate_exceeds_duration?, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # _@param_ `task`
        sig { params(task: Asana::Resources::Task).returns(Float) }
        def calculate_allocated_hours(task); end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # _@param_ `task`
        sig { params(task: Asana::Resources::Task).returns(T::Boolean) }
        def evaluate(task); end
      end

      # :dependent_on_previous_section_last_milestone?
      class DependentOnPreviousSectionLastMilestonePFunctionEvaluator < Checkoff::SelectorClasses::Task::FunctionEvaluator
        FUNCTION_NAME = T.let(:dependent_on_previous_section_last_milestone?, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # only projects in this portfolio will be evaluated.
        # 
        # _@param_ `task`
        # 
        # _@param_ `project_name`
        # 
        # _@param_ `limit_to_portfolio_gid` — If specified,
        sig { params(task: Asana::Resources::Task, limit_to_portfolio_gid: T.nilable(String)).returns(T::Boolean) }
        def evaluate(task, limit_to_portfolio_gid: nil); end
      end

      # :in_portfolio_named? function
      class InPortfolioNamedPFunctionEvaluator < Checkoff::SelectorClasses::Task::FunctionEvaluator
        FUNCTION_NAME = T.let(:in_portfolio_named?, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # _@param_ `task`
        # 
        # _@param_ `portfolio_name`
        sig { params(task: Asana::Resources::Task, portfolio_name: String).returns(T::Boolean) }
        def evaluate(task, portfolio_name); end
      end

      # :last_task_milestone_does_not_depend_on_this_task? function
      class LastTaskMilestoneDoesNotDependOnThisTaskPFunctionEvaluator < Checkoff::SelectorClasses::Task::FunctionEvaluator
        FUNCTION_NAME = T.let(:last_task_milestone_does_not_depend_on_this_task?, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        sig { params(_index: Integer).returns(T::Boolean) }
        def evaluate_arg?(_index); end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # _@param_ `task`
        # 
        # _@param_ `limit_to_portfolio_name`
        sig { params(task: Asana::Resources::Task, limit_to_portfolio_name: T.nilable(String)).returns(T::Boolean) }
        def evaluate(task, limit_to_portfolio_name = nil); end
      end

      # :milestone? function
      class MilestonePFunctionEvaluator < Checkoff::SelectorClasses::Task::FunctionEvaluator
        FUNCTION_NAME = T.let(:milestone?, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        sig { params(_index: Integer).returns(T::Boolean) }
        def evaluate_arg?(_index); end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # _@param_ `task`
        sig { params(task: Asana::Resources::Task).returns(T::Boolean) }
        def evaluate(task); end
      end

      # :milestone_does_not_depend_on_this_task? function
      class NoMilestoneDependsOnThisTaskPFunctionEvaluator < Checkoff::SelectorClasses::Task::FunctionEvaluator
        FUNCTION_NAME = T.let(:no_milestone_depends_on_this_task?, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        sig { params(_index: Integer).returns(T::Boolean) }
        def evaluate_arg?(_index); end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # _@param_ `task`
        # 
        # _@param_ `limit_to_portfolio_name`
        sig { params(task: Asana::Resources::Task, limit_to_portfolio_name: T.nilable(String)).returns(T::Boolean) }
        def evaluate(task, limit_to_portfolio_name = nil); end
      end

      # Base class to evaluate a task selector function given fully evaluated arguments
      class FunctionEvaluator < Checkoff::SelectorClasses::FunctionEvaluator
        # sord omit - no YARD type given for "**_kwargs", using untyped
        # _@param_ `selector`
        # 
        # _@param_ `tasks`
        # 
        # _@param_ `timelines`
        # 
        # _@param_ `custom_fields`
        sig do
          params(
            selector: T.any(T::Array[[Symbol, T::Array[T.untyped]]], String),
            tasks: Checkoff::Tasks,
            timelines: Checkoff::Timelines,
            custom_fields: Checkoff::CustomFields,
            _kwargs: T.untyped
          ).void
        end
        def initialize(selector:, tasks:, timelines:, custom_fields:, **_kwargs); end

        sig { returns(T::Array[[Symbol, T::Array[T.untyped]]]) }
        attr_reader :selector
      end
    end

    module Common
      # :and function
      class AndFunctionEvaluator < Checkoff::SelectorClasses::Common::FunctionEvaluator
        FUNCTION_NAME = T.let(:and, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
        # _@param_ `_resource`
        # 
        # _@param_ `args`
        sig { params(_resource: T.any(Asana::Resources::Task, Asana::Resources::Project), args: T::Array[Object]).returns(T::Boolean) }
        def evaluate(_resource, *args); end
      end

      # :or function
      # 
      # Does not yet shortcut, but may in future - be careful with side
      # effects!
      class OrFunctionEvaluator < Checkoff::SelectorClasses::Common::FunctionEvaluator
        FUNCTION_NAME = T.let(:or, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
        # _@param_ `_resource`
        # 
        # _@param_ `args`
        sig { params(_resource: T.any(Asana::Resources::Task, Asana::Resources::Project), args: T::Array[Object]).returns(T::Boolean) }
        def evaluate(_resource, *args); end
      end

      # :not function
      class NotFunctionEvaluator < Checkoff::SelectorClasses::Common::FunctionEvaluator
        FUNCTION_NAME = T.let(:not, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
        # _@param_ `_resource`
        # 
        # _@param_ `subvalue`
        sig { params(_resource: T.any(Asana::Resources::Task, Asana::Resources::Project), subvalue: Object).returns(T::Boolean) }
        def evaluate(_resource, subvalue); end
      end

      # :nil? function
      class NilPFunctionEvaluator < Checkoff::SelectorClasses::Common::FunctionEvaluator
        sig { returns(T::Boolean) }
        def matches?; end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
        # _@param_ `_resource`
        # 
        # _@param_ `subvalue`
        sig { params(_resource: T.any(Asana::Resources::Task, Asana::Resources::Project), subvalue: Object).returns(T::Boolean) }
        def evaluate(_resource, subvalue); end
      end

      # :equals? function
      class EqualsPFunctionEvaluator < Checkoff::SelectorClasses::Common::FunctionEvaluator
        FUNCTION_NAME = T.let(:equals?, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
        # _@param_ `_resource`
        # 
        # _@param_ `lhs`
        # 
        # _@param_ `rhs`
        sig { params(_resource: T.any(Asana::Resources::Task, Asana::Resources::Project), lhs: Object, rhs: Object).returns(T::Boolean) }
        def evaluate(_resource, lhs, rhs); end
      end

      # :custom_field_value function
      class CustomFieldValueFunctionEvaluator < Checkoff::SelectorClasses::Common::FunctionEvaluator
        FUNCTION_NAME = T.let(:custom_field_value, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        # _@param_ `_index`
        sig { params(_index: Integer).returns(T::Boolean) }
        def evaluate_arg?(_index); end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
        # _@param_ `resource`
        # 
        # _@param_ `custom_field_name`
        sig { params(resource: T.any(Asana::Resources::Task, Asana::Resources::Project), custom_field_name: String).returns(T.nilable(String)) }
        def evaluate(resource, custom_field_name); end
      end

      # :custom_field_gid_value function
      class CustomFieldGidValueFunctionEvaluator < Checkoff::SelectorClasses::Common::FunctionEvaluator
        sig { returns(T::Boolean) }
        def matches?; end

        sig { params(_index: Integer).returns(T::Boolean) }
        def evaluate_arg?(_index); end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
        # @sg-ignore
        # 
        # _@param_ `resource`
        # 
        # _@param_ `custom_field_gid`
        sig { params(resource: T.any(Asana::Resources::Task, Asana::Resources::Project), custom_field_gid: String).returns(T.nilable(String)) }
        def evaluate(resource, custom_field_gid); end
      end

      # :custom_field_gid_value_contains_any_gid? function
      class CustomFieldGidValueContainsAnyGidPFunctionEvaluator < Checkoff::SelectorClasses::Common::FunctionEvaluator
        FUNCTION_NAME = T.let(:custom_field_gid_value_contains_any_gid?, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        sig { params(_index: Integer).returns(T::Boolean) }
        def evaluate_arg?(_index); end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
        # _@param_ `resource`
        # 
        # _@param_ `custom_field_gid`
        # 
        # _@param_ `custom_field_values_gids`
        sig { params(resource: T.any(Asana::Resources::Task, Asana::Resources::Project), custom_field_gid: String, custom_field_values_gids: T::Array[String]).returns(T::Boolean) }
        def evaluate(resource, custom_field_gid, custom_field_values_gids); end
      end

      # :custom_field_value_contains_any_value?
      class CustomFieldValueContainsAnyValuePFunctionEvaluator < Checkoff::SelectorClasses::Common::FunctionEvaluator
        FUNCTION_NAME = T.let(:custom_field_value_contains_any_value?, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        sig { params(_index: Integer).returns(T::Boolean) }
        def evaluate_arg?(_index); end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
        # _@param_ `resource`
        # 
        # _@param_ `custom_field_name`
        # 
        # _@param_ `custom_field_value_names`
        sig { params(resource: T.any(Asana::Resources::Task, Asana::Resources::Project), custom_field_name: String, custom_field_value_names: T::Array[String]).returns(T::Boolean) }
        def evaluate(resource, custom_field_name, custom_field_value_names); end
      end

      # :custom_field_gid_value_contains_all_gids? function
      class CustomFieldGidValueContainsAllGidsPFunctionEvaluator < Checkoff::SelectorClasses::Common::FunctionEvaluator
        FUNCTION_NAME = T.let(:custom_field_gid_value_contains_all_gids?, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        sig { params(_index: Integer).returns(T::Boolean) }
        def evaluate_arg?(_index); end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
        # _@param_ `resource`
        # 
        # _@param_ `custom_field_gid`
        # 
        # _@param_ `custom_field_values_gids`
        sig { params(resource: T.any(Asana::Resources::Task, Asana::Resources::Project), custom_field_gid: String, custom_field_values_gids: T::Array[String]).returns(T::Boolean) }
        def evaluate(resource, custom_field_gid, custom_field_values_gids); end
      end

      # :name_starts_with? function
      class NameStartsWithPFunctionEvaluator < Checkoff::SelectorClasses::Common::FunctionEvaluator
        FUNCTION_NAME = T.let(:name_starts_with?, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        sig { params(_index: Integer).returns(T::Boolean) }
        def evaluate_arg?(_index); end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
        # @sg-ignore
        # 
        # _@param_ `resource`
        # 
        # _@param_ `prefix`
        sig { params(resource: T.any(Asana::Resources::Task, Asana::Resources::Project), prefix: String).returns(T::Boolean) }
        def evaluate(resource, prefix); end
      end

      # String literals
      class StringLiteralEvaluator < Checkoff::SelectorClasses::Common::FunctionEvaluator
        sig { returns(T::Boolean) }
        def matches?; end

        # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
        # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
        # @sg-ignore
        # 
        # _@param_ `_resource`
        sig { params(_resource: T.any(Asana::Resources::Task, Asana::Resources::Project)).returns(String) }
        def evaluate(_resource); end
      end

      # Base class to evaluate a project selector function given fully evaluated arguments
      class FunctionEvaluator < Checkoff::SelectorClasses::FunctionEvaluator
        # sord omit - no YARD type given for "**_kwargs", using untyped
        # _@param_ `selector`
        # 
        # _@param_ `custom_fields`
        sig { params(selector: T.any(T::Array[[Symbol, T::Array[T.untyped]]], String), custom_fields: Checkoff::CustomFields, _kwargs: T.untyped).void }
        def initialize(selector:, custom_fields:, **_kwargs); end

        sig { returns(T::Array[[Symbol, T::Array[T.untyped]]]) }
        attr_reader :selector
      end
    end

    # Project selector classes
    module Project
      # :due_date function
      class DueDateFunctionEvaluator < Checkoff::SelectorClasses::Project::FunctionEvaluator
        FUNCTION_NAME = T.let(:due_date, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
        # _@param_ `resource`
        sig { params(resource: Asana::Resources::Project).returns(T.nilable(String)) }
        def evaluate(resource); end
      end

      # :ready? function
      class ReadyPFunctionEvaluator < Checkoff::SelectorClasses::Project::FunctionEvaluator
        FUNCTION_NAME = T.let(:ready?, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
        # _@param_ `project`
        # 
        # _@param_ `period`
        sig { params(project: Asana::Resources::Project, period: Symbol).returns(T::Boolean) }
        def evaluate(project, period = :now_or_before); end
      end

      # :in_portfolio_named? function
      class InPortfolioNamedPFunctionEvaluator < Checkoff::SelectorClasses::Project::FunctionEvaluator
        FUNCTION_NAME = T.let(:in_portfolio_named?, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
        # _@param_ `project`
        # 
        # _@param_ `portfolio_name`
        # 
        # _@param_ `workspace_name`
        # 
        # _@param_ `extra_project_fields`
        sig do
          params(
            project: Asana::Resources::Project,
            portfolio_name: String,
            workspace_name: T.nilable(String),
            extra_project_fields: T::Array[String]
          ).returns(T::Boolean)
        end
        def evaluate(project, portfolio_name, workspace_name: nil, extra_project_fields: []); end
      end

      # Base class to evaluate a project selector function given fully evaluated arguments
      class FunctionEvaluator < Checkoff::SelectorClasses::FunctionEvaluator
        # sord omit - no YARD type given for "**_kwargs", using untyped
        # _@param_ `selector`
        # 
        # _@param_ `projects`
        # 
        # _@param_ `portfolios`
        # 
        # _@param_ `workspaces`
        sig do
          params(
            selector: T.any(T::Array[[Symbol, T::Array[T.untyped]]], String),
            projects: Checkoff::Projects,
            portfolios: Checkoff::Portfolios,
            workspaces: Checkoff::Workspaces,
            _kwargs: T.untyped
          ).void
        end
        def initialize(selector:, projects:, portfolios:, workspaces:, **_kwargs); end

        sig { returns(T::Array[[Symbol, T::Array[T.untyped]]]) }
        attr_reader :selector
      end
    end

    # Section selector classes
    module Section
      # :ends_with_milestone function
      class EndsWithMilestoneFunctionEvaluator < Checkoff::SelectorClasses::Section::FunctionEvaluator
        FUNCTION_NAME = T.let(:ends_with_milestone, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        # sord warn - Asana::Resources::Section wasn't able to be resolved to a constant in this project
        # @sg-ignore
        # 
        # _@param_ `section`
        sig { params(section: Asana::Resources::Section).returns(T::Boolean) }
        def evaluate(section); end
      end

      # :has_tasks? function
      class HasTasksPFunctionEvaluator < Checkoff::SelectorClasses::Section::FunctionEvaluator
        FUNCTION_NAME = T.let(:has_tasks?, T.untyped)

        sig { returns(T::Boolean) }
        def matches?; end

        # sord warn - Asana::Resources::Section wasn't able to be resolved to a constant in this project
        # @sg-ignore
        # 
        # _@param_ `section`
        sig { params(section: Asana::Resources::Section).returns(T::Boolean) }
        def evaluate(section); end
      end

      # Base class to evaluate a project selector function given fully evaluated arguments
      class FunctionEvaluator < Checkoff::SelectorClasses::FunctionEvaluator
        # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
        # _@param_ `selector`
        # 
        # _@param_ `client`
        # 
        # _@param_ `sections`
        sig { params(selector: T.any(T::Array[[Symbol, T::Array[T.untyped]]], String), sections: Checkoff::Sections, client: Asana::Client).void }
        def initialize(selector:, sections:, client:); end

        sig { returns(T::Array[[Symbol, T::Array[T.untyped]]]) }
        attr_reader :selector

        # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
        sig { returns(Asana::Client) }
        attr_reader :client
      end
    end

    # Base class to evaluate types of selector functions
    class FunctionEvaluator
      include Logging

      # @sg-ignore
      # 
      # _@param_ `_index`
      sig { params(_index: Integer).returns(T::Boolean) }
      def evaluate_arg?(_index); end

      # @sg-ignore
      sig { returns(T::Boolean) }
      def matches?; end

      # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
      # @sg-ignore
      # 
      # _@param_ `_task`
      # 
      # _@param_ `_args`
      sig { params(_task: Asana::Resources::Task, _args: T::Array[Object]).returns(Object) }
      def evaluate(_task, *_args); end

      # _@param_ `object`
      # 
      # _@param_ `fn_name`
      sig { params(object: Object, fn_name: Symbol).returns(T::Boolean) }
      def fn?(object, fn_name); end

      sig { returns(::Logger) }
      def logger; end

      # _@param_ `message`
      sig { params(message: T.nilable(String), block: T.untyped).void }
      def error(message = nil, &block); end

      # _@param_ `message`
      sig { params(message: T.nilable(String), block: T.untyped).void }
      def warn(message = nil, &block); end

      # _@param_ `message`
      sig { params(message: T.nilable(String), block: T.untyped).void }
      def info(message = nil, &block); end

      # _@param_ `message`
      sig { params(message: T.nilable(String), block: T.untyped).void }
      def debug(message = nil, &block); end

      # _@param_ `message`
      sig { params(message: T.nilable(String), block: T.untyped).void }
      def finer(message = nil, &block); end

      # @sg-ignore
      sig { returns(Symbol) }
      def log_level; end
    end
  end

  # Evaluates task selectors against a task
  class TaskSelectorEvaluator < Checkoff::SelectorEvaluator
    COMMON_FUNCTION_EVALUATORS = T.let((Checkoff::SelectorClasses::Common.constants.map do |const|
  Checkoff::SelectorClasses::Common.const_get(const)
end - [Checkoff::SelectorClasses::Common::FunctionEvaluator]).freeze, T.untyped)
    TASK_FUNCTION_EVALUATORS = T.let((Checkoff::SelectorClasses::Task.constants.map do |const|
  Checkoff::SelectorClasses::Task.const_get(const)
end - [Checkoff::SelectorClasses::Task::FunctionEvaluator]).freeze, T.untyped)
    FUNCTION_EVALUTORS = T.let((COMMON_FUNCTION_EVALUATORS + TASK_FUNCTION_EVALUATORS).freeze, T.untyped)

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    # _@param_ `task`
    # 
    # _@param_ `tasks`
    # 
    # _@param_ `timelines`
    # 
    # _@param_ `custom_fields`
    sig do
      params(
        task: Asana::Resources::Task,
        tasks: Checkoff::Tasks,
        timelines: Checkoff::Timelines,
        custom_fields: Checkoff::CustomFields
      ).void
    end
    def initialize(task:, tasks: Checkoff::Tasks.new, timelines: Checkoff::Timelines.new, custom_fields: Checkoff::CustomFields.new); end

    # sord warn - TaskSelectorClasses::FunctionEvaluator wasn't able to be resolved to a constant in this project
    sig { returns(T::Array[T.class_of(Checkoff::SelectorClasses::FunctionEvaluator)]) }
    def function_evaluators; end

    sig { returns(T::Hash[T.untyped, T.untyped]) }
    def initializer_kwargs; end

    # sord warn - Asana::Resources::Task wasn't able to be resolved to a constant in this project
    sig { returns(Asana::Resources::Task) }
    attr_reader :item

    sig { returns(Checkoff::Tasks) }
    attr_reader :tasks

    sig { returns(Checkoff::Timelines) }
    attr_reader :timelines

    sig { returns(Checkoff::CustomFields) }
    attr_reader :custom_fields
  end

  # Evaluates project selectors against a project
  class ProjectSelectorEvaluator < Checkoff::SelectorEvaluator
    COMMON_FUNCTION_EVALUATORS = T.let((Checkoff::SelectorClasses::Common.constants.map do |const|
  Checkoff::SelectorClasses::Common.const_get(const)
end - [Checkoff::SelectorClasses::Common::FunctionEvaluator]).freeze, T.untyped)
    PROJECT_FUNCTION_EVALUATORS = T.let((Checkoff::SelectorClasses::Project.constants.map do |const|
  Checkoff::SelectorClasses::Project.const_get(const)
end - [Checkoff::SelectorClasses::Project::FunctionEvaluator]).freeze, T.untyped)
    FUNCTION_EVALUTORS = T.let((COMMON_FUNCTION_EVALUATORS + PROJECT_FUNCTION_EVALUATORS).freeze, T.untyped)

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # _@param_ `project`
    # 
    # _@param_ `projects`
    # 
    # _@param_ `custom_fields`
    # 
    # _@param_ `workspaces`
    # 
    # _@param_ `portfolios`
    sig do
      params(
        project: Asana::Resources::Project,
        projects: Checkoff::Projects,
        custom_fields: Checkoff::CustomFields,
        workspaces: Checkoff::Workspaces,
        portfolios: Checkoff::Portfolios
      ).void
    end
    def initialize(project:, projects: Checkoff::Projects.new, custom_fields: Checkoff::CustomFields.new, workspaces: Checkoff::Workspaces.new, portfolios: Checkoff::Portfolios.new); end

    # sord warn - ProjectSelectorClasses::FunctionEvaluator wasn't able to be resolved to a constant in this project
    sig { returns(T::Array[T.class_of(Checkoff::ProjectSelectors::FunctionEvaluator)]) }
    def function_evaluators; end

    sig { returns(T::Hash[T.untyped, T.untyped]) }
    def initializer_kwargs; end

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    sig { returns(Asana::Resources::Project) }
    attr_reader :item

    sig { returns(Checkoff::Projects) }
    attr_reader :projects

    sig { returns(Checkoff::CustomFields) }
    attr_reader :custom_fields

    sig { returns(Checkoff::Workspaces) }
    attr_reader :workspaces

    sig { returns(Checkoff::Portfolios) }
    attr_reader :portfolios
  end

  # Evaluates section selectors against a section
  class SectionSelectorEvaluator < Checkoff::SelectorEvaluator
    COMMON_FUNCTION_EVALUATORS = T.let((Checkoff::SelectorClasses::Common.constants.map do |const|
  Checkoff::SelectorClasses::Common.const_get(const)
end - [Checkoff::SelectorClasses::Common::FunctionEvaluator]).freeze, T.untyped)
    SECTION_FUNCTION_EVALUATORS = T.let((Checkoff::SelectorClasses::Section.constants.map do |const|
  Checkoff::SelectorClasses::Section.const_get(const)
end - [Checkoff::SelectorClasses::Section::FunctionEvaluator]).freeze, T.untyped)
    FUNCTION_EVALUTORS = T.let((COMMON_FUNCTION_EVALUATORS + SECTION_FUNCTION_EVALUATORS).freeze, T.untyped)

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    # sord omit - no YARD type given for "**_kwargs", using untyped
    # _@param_ `section`
    # 
    # _@param_ `client`
    # 
    # _@param_ `projects`
    # 
    # _@param_ `sections`
    # 
    # _@param_ `custom_fields`
    sig do
      params(
        section: Asana::Resources::Project,
        client: Asana::Client,
        projects: Checkoff::Projects,
        sections: Checkoff::Sections,
        custom_fields: Checkoff::CustomFields,
        _kwargs: T.untyped
      ).void
    end
    def initialize(section:, client:, projects: Checkoff::Projects.new(client: client), sections: Checkoff::Sections.new(client: client), custom_fields: Checkoff::CustomFields.new(client: client), **_kwargs); end

    # sord warn - ProjectSelectorClasses::FunctionEvaluator wasn't able to be resolved to a constant in this project
    sig { returns(T::Array[T.class_of(Checkoff::ProjectSelectors::FunctionEvaluator)]) }
    def function_evaluators; end

    sig { returns(T::Hash[T.untyped, T.untyped]) }
    def initializer_kwargs; end

    # sord warn - Asana::Resources::Project wasn't able to be resolved to a constant in this project
    sig { returns(Asana::Resources::Project) }
    attr_reader :item

    sig { returns(Checkoff::Sections) }
    attr_reader :sections

    sig { returns(Checkoff::Projects) }
    attr_reader :projects

    sig { returns(Checkoff::CustomFields) }
    attr_reader :custom_fields

    # sord warn - Asana::Client wasn't able to be resolved to a constant in this project
    sig { returns(Asana::Client) }
    attr_reader :client
  end
end

# include this to add ability to log at different levels
module Logging
  sig { returns(::Logger) }
  def logger; end

  # _@param_ `message`
  sig { params(message: T.nilable(String), block: T.untyped).void }
  def error(message = nil, &block); end

  # _@param_ `message`
  sig { params(message: T.nilable(String), block: T.untyped).void }
  def warn(message = nil, &block); end

  # _@param_ `message`
  sig { params(message: T.nilable(String), block: T.untyped).void }
  def info(message = nil, &block); end

  # _@param_ `message`
  sig { params(message: T.nilable(String), block: T.untyped).void }
  def debug(message = nil, &block); end

  # _@param_ `message`
  sig { params(message: T.nilable(String), block: T.untyped).void }
  def finer(message = nil, &block); end

  # @sg-ignore
  sig { returns(Symbol) }
  def log_level; end
end

# Monkeypatches Asana::Resources::Resource so that Ruby marshalling and
# unmarshalling works on Asana resource classes.  Currently, it will
# work unless you call an accessor method, which triggers Asana's
# client library Resource class' method_missing() to "cache" the
# result by creating a singleton method.  Unfortunately, singleton
# methods break marshalling, which is not smart enough to know that it
# is not necessary to marshall them as they will simply be recreated
# when needed.
module Asana
  # Monkeypatches:
  # 
  # https://github.com/Asana/ruby-asana/blob/master/lib/asana
  module Resources
    # Public: The base resource class which provides some sugar over common
    # resource functionality.
    class Resource
      sig { returns(T::Hash[T.untyped, T.untyped]) }
      def marshal_dump; end

      # _@param_ `data`
      sig { params(data: T::Hash[T.untyped, T.untyped]).void }
      def marshal_load(data); end
    end
  end
end
