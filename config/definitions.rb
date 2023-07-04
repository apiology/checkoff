# frozen_string_literal: true
#
# rubocop:disable Layout/LineLength
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
#       # @return [Asana::ProxiedResourceClasses::Project]
#       def projects; end
#       # @return [Asana::ProxiedResourceClasses::UserTaskList]
#       def user_task_lists; end
#     end
#     class Collection < Asana::Resources::Collection; end
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
#         # Returns the compact task records for some filtered set of tasks. Use one
#         # or more of the parameters provided to filter the tasks returned. You must
#         # specify a `project`, `section`, `tag`, or `user_task_list` if you do not
#         # specify `assignee` and `workspace`.
#         #
#         # @param assignee [String] The assignee to filter tasks on.
#         # @param workspace [String] The workspace or organization to filter tasks on.
#         # @param project [String] The project to filter tasks on.
#         # @param section [Gid] The section to filter tasks on.
#         # @param tag [Gid] The tag to filter tasks on.
#         # @param user_task_list [Gid] The user task list to filter tasks on.
#         # @param completed_since [String] Only return tasks that are either incomplete or that have been
#         # completed since this time.
#         #
#         # @param modified_since [String] Only return tasks that have been modified since the given time.
#         #
#         # @param per_page [Integer] the number of records to fetch per page.
#         # @param options [Hash] the request I/O options.
#         # Notes:
#         #
#         # If you specify `assignee`, you must also specify the `workspace` to filter on.
#         #
#         # If you specify `workspace`, you must also specify the `assignee` to filter on.
#         #
#         # Currently, this is only supported in board views.
#         #
#         # A task is considered "modified" if any of its properties change,
#         # or associations between it and other objects are modified (e.g.
#         # a task being added to a project). A task is not considered modified
#         # just because another object it is associated with (e.g. a subtask)
#         # is modified. Actions that count as modifying the task include
#         # assigning, renaming, completing, and adding stories.
#         # @return [Asana::Collection<Asana::Resources::Task>]
#         def find_all(assignee: nil, workspace: nil, project: nil, section: nil,
#                      tag: nil, user_task_list: nil, completed_since: nil,
#                      modified_since: nil, per_page: 20, options: {}); end
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
#       class Project
#         # Returns the compact project records for all projects in the workspace.
#         #
#         # @param workspace [Strin] The workspace or organization to find projects in.
#         # @param is_template [Boolean] **Note: This parameter can only be included if a team is also defined, or the workspace is not an organization**
#         # Filters results to include only template projects.
#         #
#         # @param archived [Boolean] Only return projects whose `archived` field takes on the value of
#         # this parameter.
#         #
#         # @param per_page [Integer] the number of records to fetch per page.
#         # @param options [Hash] the request I/O options.
#         # @return [Asana::Collection<Asana::Resources::Project>]
#         def find_by_workspace(client, workspace: required("workspace"), is_template: nil, archived: nil, per_page: 20, options: {}); end
#         # Returns the complete project record for a single project.
#         #
#         # @param id [String] The project to get.
#         # @param options [Hash] the request I/O options.
#         # @return [Asana::Resources::Project]
#         def find_by_id(id, options: {}); end
#       end
#       class UserTaskList
#         # @param user_gid [String]  (required) A string identifying a user. This can either be the string \"me\", an email, or the gid of a user.
#         # @param workspace [String]  (required) The workspace in which to get the user task list.
#         # @param options [Hash] the request I/O options
#         # @return [Asana::Resources::UserTaskList]
#         def get_user_task_list_for_user(client, user_gid:,
#             workspace: nil, options: {}); end
#       end
#     end
#   end
# rubocop:enable Layout/LineLength
