# frozen_string_literal: true

module Checkoff
  module Internal
    # Determine whether a task is due within a relative date range
    class ReadyBetweenRelative
      # @param config [Hash<Symbol, Object>]
      # @param clients [Checkoff::Clients]
      # @param task_timing [Checkoff::Internal::TaskTiming]
      # @param tasks [Checkoff::Tasks]
      def initialize(config: Checkoff::Internal::ConfigLoader.load(:asana),
                     clients: Checkoff::Clients.new(config: config),
                     task_timing: ::Checkoff::Internal::TaskTiming.new,
                     tasks: ::Checkoff::Tasks.new(config: config,
                                                  client: clients.client))
        @task_timing = task_timing
        @tasks = tasks
      end

      # @param task [Asana::Resources::Task]
      # @param beginning_num_days_from_now [Integer]
      # @param end_num_days_from_now [Integer]
      # @param ignore_dependencies [Boolean]
      #
      # @return [Boolean]
      def ready_between_relative?(task,
                                  beginning_num_days_from_now,
                                  end_num_days_from_now,
                                  ignore_dependencies: false)
        beginning_n_days_from_now_time = (Time.now + (beginning_num_days_from_now * 24 * 60 * 60))
        end_n_days_from_now_time = (Time.now + (end_num_days_from_now * 24 * 60 * 60))

        # @type [Date, Time, nil]
        ready_date_or_time = @task_timing.date_or_time_field_by_name(task, :ready)

        return false if ready_date_or_time.nil?

        in_range = ready_in_range?(ready_date_or_time,
                                   beginning_n_days_from_now_time,
                                   end_n_days_from_now_time)

        return false unless in_range

        return false if !ignore_dependencies && @tasks.incomplete_dependencies?(task)

        true
      end

      private

      # @param ready_date_or_time [Date, Time]
      # @param start_time [Time]
      # @param end_time [Time]
      def ready_in_range?(ready_date_or_time, start_time, end_time)
        if ready_date_or_time.is_a?(Time)
          ready_date_or_time > start_time && ready_date_or_time <= end_time
        else
          ready_date_or_time > start_time.to_date && ready_date_or_time <= end_time.to_date
        end
      end
    end
  end
end
