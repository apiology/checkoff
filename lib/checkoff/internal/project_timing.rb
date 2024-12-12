# typed: false
# frozen_string_literal: true

require 'checkoff/custom_fields'

module Checkoff
  module Internal
    # Utility methods for working with project dates and times
    class ProjectTiming
      # @param time_class [Class<Time>]
      # @param date_class [Class<Date>]
      # @param client [Asana::Client]
      # @param custom_fields [Checkoff::CustomFields]
      def initialize(time_class: Time, date_class: Date,
                     client: Checkoff::Clients.new.client,
                     custom_fields: Checkoff::CustomFields.new(client: client))
        @time_class = time_class
        @date_class = date_class
        @custom_fields = custom_fields
      end

      # @param project [Asana::Resources::Project]
      # @param field_name [Symbol]
      #
      # @sg-ignore
      # @return [Date, nil]
      def start_date(project)
        return @date_class.parse(project.start_on) unless project.start_on.nil?

        nil
      end

      # @param project [Asana::Resources::Project]
      # @param field_name [Symbol]
      #
      # @sg-ignore
      # @return [Date, nil]
      def due_date(project)
        return @date_class.parse(project.due_on) unless project.due_on.nil?

        nil
      end

      # @param project [Asana::Resources::Project]
      # @param custom_field_name [String]
      #
      # @return [Time, Date, nil]
      def custom_field(project, custom_field_name)
        custom_field = @custom_fields.resource_custom_field_by_name_or_raise(project, custom_field_name)
        # @sg-ignore
        # @type [String, nil]
        time_str = custom_field.fetch('display_value')
        return nil if time_str.nil?

        Time.parse(time_str)
      end

      # @param project [Asana::Resources::Project]
      # @param field_name [Symbol,Array]
      #
      # @sg-ignore
      # @return [Date, Time, nil]
      def date_or_time_field_by_name(project, field_name)
        return due_date(project) if field_name == :due

        return start_date(project) if field_name == :start

        return start_date(project) if field_name == :ready

        if field_name.is_a?(Array)
          # @sg-ignore
          # @type [Symbol]
          actual_field_name = field_name.first
          args = field_name[1..]

          return custom_field(project, *args) if actual_field_name == :custom_field
        end

        raise "Teach me how to handle field #{field_name.inspect}"
      end
    end
  end
end
