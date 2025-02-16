#!/usr/bin/env ruby
# typed: false

# frozen_string_literal: true

require 'faraday'
require 'forwardable'
require 'cache_method'
require 'mime/types'
require 'net/http'
require 'net/http/response'
require 'net/http/responses'
require 'openssl'
require 'tempfile'
require_relative 'internal/config_loader'
require_relative 'internal/logging'
require_relative 'workspaces'
require_relative 'tasks'
require_relative 'clients'

# https://developers.asana.com/reference/attachments

module Checkoff
  # Manage attachments in Asana
  class Attachments
    # @!parse
    #   extend CacheMethod::ClassMethods

    include Logging

    MINUTE = 60
    private_constant :MINUTE
    HOUR = MINUTE * 60
    private_constant :HOUR
    DAY = 24 * HOUR
    private_constant :DAY
    REALLY_LONG_CACHE_TIME = HOUR * 1
    private_constant :REALLY_LONG_CACHE_TIME
    LONG_CACHE_TIME = MINUTE * 15
    private_constant :LONG_CACHE_TIME
    SHORT_CACHE_TIME = MINUTE
    private_constant :SHORT_CACHE_TIME

    # @param config [Hash,Checkoff::Internal::EnvFallbackConfigLoader]
    # @param workspaces [Checkoff::Workspaces]
    # @param clients [Checkoff::Clients]
    # @param client [Asana::Client]
    def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                   workspaces: Checkoff::Workspaces.new(config:),
                   clients: Checkoff::Clients.new(config:),
                   client: clients.client)
      @workspaces = workspaces
      @client = client
    end

    # @param url [String]
    # @param resource [Asana::Resources::Resource]
    # @param attachment_name [String,nil]
    # @param just_the_url [Boolean]
    # @param verify_mode [Integer] - e.g., OpenSSL::SSL::VERIFY_NONE or OpenSSL::SSL::VERIFY_PEER
    #
    # @return [Asana::Resources::Attachment]
    def create_attachment_from_url!(url,
                                    resource,
                                    attachment_name: nil,
                                    verify_mode: OpenSSL::SSL::VERIFY_PEER,
                                    just_the_url: false)
      if just_the_url
        create_attachment_from_url_alone!(url, resource, attachment_name:)
      else
        create_attachment_from_downloaded_url!(url, resource, attachment_name:,
                                                              verify_mode:)
      end
    end

    private

    # Writes contents of URL to a temporary file with the same
    # extension as the URL using Net::HTTP, raising an exception if
    # not succesful
    #
    # @param uri [URI]
    # @param verify_mode [Integer] - e.g., OpenSSL::SSL::VERIFY_NONE,OpenSSL::SSL::VERIFY_PEER
    #
    # @return [Object]
    # @sg-ignore
    def download_uri(uri, verify_mode: OpenSSL::SSL::VERIFY_PEER, &block)
      out = nil
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https', verify_mode:) do |http|
        # @sg-ignore
        http.request(Net::HTTP::Get.new(uri)) do |response|
          raise("Unexpected response code: #{response.code}") unless response.code == '200'

          write_tempfile_from_response(response) { |tempfile| out = block.yield tempfile }
        end
      end
      out
    rescue StandardError => e
      debug { e }
      raise "Error downloading #{uri}: #{e}"
    end

    # @sg-ignore
    # @param response [Net::HTTPResponse]
    #
    # @yields [IO]
    #
    # @return [Object]
    def write_tempfile_from_response(response)
      Tempfile.create('checkoff') do |tempfile|
        tempfile.binmode
        # @sg-ignore
        response.read_body do |chunk|
          tempfile.write(chunk)
        end
        tempfile.rewind

        yield tempfile
      end
    end

    # @param url [String]
    # @param resource [Asana::Resources::Resource]
    # @param attachment_name [String,nil]
    # @param verify_mode [Integer] - e.g., OpenSSL::SSL::VERIFY_NONE,OpenSSL::SSL::VERIFY_PEER
    #
    # @return [Asana::Resources::Attachment]
    def create_attachment_from_downloaded_url!(url, resource, attachment_name:,
                                               verify_mode: OpenSSL::SSL::VERIFY_PEER)
      uri = URI(url)
      attachment_name ||= File.basename(uri.path)
      download_uri(uri, verify_mode:) do |tempfile|
        content_type ||= content_type_from_filename(attachment_name)
        content_type ||= content_type_from_filename(uri.path)

        resource.attach(filename: attachment_name, mime: content_type,
                        io: tempfile)
      end
    end

    # @param url [String]
    # @param resource [Asana::Resources::Resource]
    # @param attachment_name [String,nil]
    #
    # @return [Asana::Resources::Attachment]
    def create_attachment_from_url_alone!(url, resource, attachment_name:)
      with_params = {
        'parent' => resource.gid,
        'url' => url,
        'resource_subtype' => 'external',
        'name' => attachment_name,
      }
      options = {}
      Asana::Resources::Resource.new(parse(client.post('/attachments', body: with_params, options:)).first,
                                     client:)
    end

    # @param filename [String]
    #
    # @return [String,nil]
    # @sg-ignore
    def content_type_from_filename(filename)
      # @sg-ignore
      MIME::Types.type_for(filename)&.first&.content_type
    end

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

    # @return [Checkoff::Workspaces]
    attr_reader :workspaces

    # @return [Asana::Client]
    attr_reader :client

    # bundle exec ./attachments.rb
    # :nocov:
    class << self
      # @return [void]
      def run
        # @sg-ignore
        # @type [String]
        gid = ARGV[0] || raise('Please pass task gid as first argument')
        # @sg-ignore
        # @type [String]
        url = ARGV[1] || raise('Please pass attachment URL as second argument')

        tasks = Checkoff::Tasks.new
        attachments = Checkoff::Attachments.new
        task = tasks.task_by_gid(gid)
        attachment = attachments.create_attachment_from_url!(url, task)
        puts "Results: #{attachment.inspect}"
      end
    end
    # :nocov:
  end
end

# :nocov:
abs_program_name = File.expand_path($PROGRAM_NAME)
Checkoff::Attachments.run if abs_program_name == File.expand_path(__FILE__)
# :nocov:
