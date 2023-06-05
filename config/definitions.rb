# frozen_string_literal: true
#
# @!parse
#   class Time
#     class << self
#       # @param date [String]
#       # @return [Time]
#       def parse(date); end
#     end
#   end
#   module Asana
#     class Client
#       # @return [Asana::ProxiedResourceClasses::Task]
#       def tasks; end
#       # @return [Asana::ProxiedResourceClasses::Workspace]
#       def workspaces; end
#       # @return [Asana::ProxiedResourceClasses::Section]
#       def sections; end
#     end
#     module Resources
#       class Task
#         # @return [String, nil]
#         def html_notes; end
#         class << self
#           # @return [Asana::Resources::Task]
#           def create(client, assignee:, workspace:, name:); end
#         end
#       end
#     end
#     module Resources
#       class Workspace
#         # @return [String, nil]
#         def html_notes; end
#         class << self
#           # @return [Asana::Resources::Workspace]
#           def find_by_id(client, id, options: {}); end
#         end
#       end
#     end
#     module ProxiedResourceClasses
#       class Task
#         # Returns the complete task record for a single task.
#         #
#         # @param id [String] The task to get.
#         # @param options [Hash] the request I/O options.
#         # @return [Asana::Resources::Task]
#         def find_by_id(id, options: {}); end
#         # @param section [Asana::Resources::section]
#         # @param options [Hash] the request I/O options.
#         # @return [Array<Asana::Resources::Task>]
#         def get_tasks(assignee: nil,
#                       project: nil,
#                       section: nil,
#                       workspace: nil,
#                       completed_since: nil,
#                       per_page: 20,
#                       modified_since: nil,
#                       options: {}); end
#       end
#       class Workspace
#         # @return [Array<Asana::Resources::Workspace>]
#         def find_all; end
#       end
#       class Section
#         # @param project_gid [String]
#         # @return [Array<Asana::Resources::Section>]
#         def get_sections_for_project(client, project_gid:, options: {}); end
#       end
#     end
#   end
