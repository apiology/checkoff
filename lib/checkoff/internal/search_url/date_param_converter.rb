# frozen_string_literal: true

require_relative 'custom_field_param_converter'

module Checkoff
  module Internal
    module SearchUrl
      # Convert date parameters - ones where the param name itself
      # doesn't encode any parameters'
      class DateParamConverter
        # @param date_url_params [Hash<String, Array<String>>] the simple params
        def initialize(date_url_params:)
          @date_url_params = date_url_params
        end

        # @return [Array(Hash<String, String>, Array<[Symbol, Array]>)] See https://developers.asana.com/docs/search-tasks-in-a-workspace
        def convert
          return [{}, []] if date_url_params.empty?

          # example params:
          #   due_date.operator=through_next
          #   due_date.value=0
          #   due_date.unit=day
          validate_due_date_through_next!

          value = date_url_params.fetch('due_date.value').fetch(0).to_i

          # @sg-ignore
          # @type [Date]
          before = Date.today + value

          validate_unit_is_day!

          # 'due_on.before' => '2023-01-01',
          # 'due_on.after' => '2023-01-01',
          # [{ 'due_on.before' => '2023-09-01' }, []]
          [{ 'due_on.before' => before.to_s }, []]
        end

        private

        # @return [void]
        def validate_unit_is_day!
          unit = date_url_params.fetch('due_date.unit').fetch(0)

          raise 'Teach me how to handle other time units' unless unit == 'day'
        end

        # @return [void]
        def validate_due_date_through_next!
          due_date_operators = date_url_params.fetch('due_date.operator')

          return if due_date_operators == ['through_next']

          raise "Teach me how to handle date mode: #{due_date_operators}."
        end

        # @return [Hash<String, Array<String>>]
        attr_reader :date_url_params
      end
    end
  end
end
