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
        def handle_through_next
          due_date_value = get_single_param('due_date.value').to_i

          validate_unit_is_day!

          # @sg-ignore
          # @type [Date]
          before = Date.today + due_date_value
          # 'due_on.before' => '2023-01-01',
          # 'due_on.after' => '2023-01-01',
          # [{ 'due_on.before' => '2023-09-01' }, []]
          [{ 'due_on.before' => before.to_s }, []]
        end

        # @return [Array(Hash<String, String>, Array<[Symbol, Array]>)] See https://developers.asana.com/docs/search-tasks-in-a-workspace
        def handle_between
          due_date_after = get_single_param('due_date.after')
          raise 'Teach me how to handle due_date_before' if date_url_params.key? 'due_date.before'

          validate_unit_not_provided!

          # Example value: 1702857600000
          # +1 is because API seems to operate on inclusive ranges
          # @type [Date]
          # @sg-ignore
          after = Time.at(due_date_after.to_i / 1000).to_date + 1
          [{ 'due_on.after' => after.to_s }, []]
        end

        # @param param_key [String]
        # @return [String]
        def get_single_param(param_key)
          raise "Expected #{param_key} to have at least one value" unless date_url_params.key? param_key

          value = date_url_params.fetch(param_key)

          raise "Expected #{param_key} to have one value" if value.length != 1

          value[0]
        end

        # @return [Array(Hash<String, String>, Array<[Symbol, Array]>)]
        def convert
          return [{}, []] if date_url_params.empty?

          # example params:
          #   due_date.operator=through_next
          #   due_date.value=0
          #   due_date.unit=day
          due_date_operator = get_single_param('due_date.operator')

          return handle_through_next if due_date_operator == 'through_next'

          return handle_between if due_date_operator == 'between'

          raise "Teach me how to handle date mode: #{due_date_operator.inspect}."
        end

        private

        # @return [void]
        def validate_unit_not_provided!
          return unless date_url_params.key? 'due_date.unit'

          raise "Teach me how to handle other due_date.unit for these params: #{date_url_params.inspect}"
        end

        # @return [void]
        def validate_unit_is_day!
          unit = date_url_params.fetch('due_date.unit').fetch(0)

          raise 'Teach me how to handle other time units' unless unit == 'day'
        end

        # @return [Hash<String, Array<String>>]
        attr_reader :date_url_params
      end
    end
  end
end
