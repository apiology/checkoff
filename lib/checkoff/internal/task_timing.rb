# frozen_string_literal: true

module Checkoff
  module Internal
    # Utility methods for working with task dates and times
    class TaskTiming
      # @param time_class [Class<Time>]
      # @param date_class [Class<Date>]
      def initialize(time_class: Time, date_class: Date)
        @time_class = time_class
        @date_class = date_class
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
      # @param field_name [Symbol]
      #
      # @sg-ignore
      # @return [Date, Time, nil]
      def date_or_time_field_by_name(task, field_name)
        return due_date_or_time(task) if field_name == :due

        return start_date_or_time(task) if field_name == :start

        return modified_time(task) if field_name == :modified

        return start_date_or_time(task) || due_date_or_time(task) if field_name == :ready

        raise "Teach me how to handle field #{field_name}"
      end
    end
  end
end
