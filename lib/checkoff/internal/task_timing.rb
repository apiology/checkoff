# frozen_string_literal: true

module Checkoff
  module Internal
    # Utility methods for working with task dates and times
    class TaskTiming
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

      # @param task [Asana::Resources::Task]
      # @return [Time, nil]
      def start_time(task)
        date_or_time_field_by_name(task, :start)&.to_time
      end

      # @param task [Asana::Resources::Task]
      # @return [Time, nil]
      def due_time(task)
        date_or_time_field_by_name(task, :due)&.to_time
      end

      # @param task [Asana::Resources::Task]
      # @param field_name [Symbol]
      #
      # @sg-ignore
      # @return [Date, Time, nil]
      def start_date_or_time(task)
        return @time_class.parse(task.start_at) unless task.start_at.nil?

        return @date_class.parse(task.start_on) unless task.start_on.nil?

        nil
      end

      # @param task [Asana::Resources::Task]
      # @param field_name [Symbol]
      #
      # @sg-ignore
      # @return [Date, Time, nil]
      def due_date_or_time(task)
        return @time_class.parse(task.due_at) unless task.due_at.nil?

        return @date_class.parse(task.due_on) unless task.due_on.nil?

        nil
      end

      # @param task [Asana::Resources::Task]
      #
      # @return [Time, nil]
      def modified_time(task)
        return @time_class.parse(task.modified_at) unless task.modified_at.nil?
      end

      # @param task [Asana::Resources::Task]
      # @param custom_field_name [String]
      #
      # @return [Time, Date, nil]
      def custom_field(task, custom_field_name)
        custom_field = @custom_fields.resource_custom_field_by_name_or_raise(task, custom_field_name)
        # @sg-ignore
        # @type [String, nil]
        time_str = custom_field.fetch('display_value')
        return nil if time_str.nil?

        Time.parse(time_str)
      end

      # @param task [Asana::Resources::Task]
      # @param field_name [Symbol]
      #
      # @sg-ignore
      # @return [Date, Time, nil]
      def date_or_time_field_by_name(task, field_name)
        return due_date_or_time(task) if field_name == :due

        return start_date_or_time(task) if field_name == :start

        return modified_time(task) if field_name == :modified

        return start_date_or_time(task) || due_date_or_time(task) if field_name == :ready

        if field_name.is_a?(Array)
          # @sg-ignore
          # @type [Symbol]
          actual_field_name = field_name.first
          args = field_name[1..]

          return custom_field(task, *args) if actual_field_name == :custom_field
        end

        raise "Teach me how to handle field #{field_name}"
      end
    end
  end
end
