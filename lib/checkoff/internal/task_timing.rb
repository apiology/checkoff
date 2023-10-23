# frozen_string_literal: true

module Checkoff
  module Internal
    # Utility methods for working with task dates and times
    class TaskTiming
      # @param time_class [Class<Time>]
      def initialize(time_class: Time)
        @time_class = time_class
      end

      # @param task [Asana::Resources::Task]
      # @return [Time, nil]
      def start_time(task)
        return @time_class.parse(task.start_at) if task.start_at
        return @time_class.parse(task.start_on) if task.start_on

        nil
      end

      # @param task [Asana::Resources::Task]
      # @return [Time, nil]
      def due_time(task)
        return @time_class.parse(task.due_at) if task.due_at
        return @time_class.parse(task.due_on) if task.due_on

        nil
      end
    end
  end
end
