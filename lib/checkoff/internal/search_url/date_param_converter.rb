# typed: false
# frozen_string_literal: true

require_relative 'custom_field_param_converter'

module Checkoff
  module Internal
    module SearchUrl
      # Convert date parameters - ones where the param name itself
      # doesn't encode any parameters'
      class DateParamConverter
        # @param date_url_params [Hash{String => Array<String>}] the simple params
        def initialize(date_url_params:)
          @date_url_params = date_url_params
        end

        # @sg-ignore
        # @return [Array(Hash{String => String}, Array<Symbol, Array>)]
        def convert
          return [{}, []] if date_url_params.empty?

          out = nil

          %w[due_date start_date completion_date].each do |prefix|
            next unless date_url_params.key? "#{prefix}.operator"
            raise 'Teach me how to handle simultaneous date parameters' unless out.nil?

            out = convert_for_prefix(prefix)
          end

          raise "Teach me to handle these parameters: #{date_url_params.inspect}" unless date_url_params.empty?

          out
        end

        private

        # @param prefix [String]
        # @return [Array(Hash{String => String}, Array<Symbol, Array>)]
        def convert_for_prefix(prefix)
          # example params:
          #   due_date.operator=through_next
          #   due_date.value=0
          #   due_date.unit=day
          operator = get_single_param("#{prefix}.operator")

          out = case operator
                when 'through_next'
                  handle_through_next(prefix)
                when 'between'
                  handle_between(prefix)
                when 'within_last'
                  handle_within_last(prefix)
                when 'within_next'
                  handle_within_next(prefix)
                else
                  raise "Teach me how to handle date mode: #{operator.inspect}."
                end

          # mark these as done by deleting from the hash
          date_url_params.delete_if { |k, _| k.start_with? prefix }

          out
        end

        # https://developers.asana.com/docs/search-tasks-in-a-workspace
        API_PREFIX = {
          'due_date' => 'due_on',
          'start_date' => 'start_on',
          'completion_date' => 'completed_on',
        }.freeze
        private_constant :API_PREFIX

        # @param prefix [String]
        # @return [Array(Hash{String => String}, Array<Symbol, Array>)] See https://developers.asana.com/docs/search-tasks-in-a-workspace
        def handle_through_next(prefix)
          value = get_single_param("#{prefix}.value").to_i

          validate_unit_is_day!(prefix)

          # @sg-ignore
          # @type [Date]
          before = Date.today + value

          # 'due_on.before' => '2023-01-01',
          # 'due_on.after' => '2023-01-01',
          # [{ 'due_on.before' => '2023-09-01' }, []]
          [{ "#{API_PREFIX.fetch(prefix)}.before" => before.to_s }, []]
        end

        # @param prefix [String]
        # @return [Array(Hash{String => String}, Array<Symbol, Array>)] See https://developers.asana.com/docs/search-tasks-in-a-workspace
        def handle_between(prefix)
          after = get_single_param("#{prefix}.after")
          raise "Teach me how to handle #{prefix}.before" if date_url_params.key? "#{prefix}.before"

          validate_unit_not_provided!(prefix)

          # Example value: 1702857600000
          # +1 is because API seems to operate on inclusive ranges
          # @type [Date]
          # @sg-ignore
          after = Time.at(after.to_i / 1000).to_date + 1
          [{ "#{API_PREFIX.fetch(prefix)}.after" => after.to_s }, []]
        end

        # @param prefix [String]
        # @return [Array(Hash{String => String}, Array<Symbol, Array>)] See https://developers.asana.com/docs/search-tasks-in-a-workspace
        def handle_within_last(prefix)
          value = get_single_param("#{prefix}.value").to_i

          validate_unit_is_day!(prefix)

          # @sg-ignore
          # @type [Date]
          after = Date.today - value

          [{ "#{API_PREFIX.fetch(prefix)}.after" => after.to_s }, []]
        end

        # @param prefix [String]
        # @return [Array(Hash{String => String}, Array<Symbol, Array>)] See https://developers.asana.com/docs/search-tasks-in-a-workspace
        def handle_within_next(prefix)
          value = get_single_param("#{prefix}.value").to_i

          validate_unit_is_day!(prefix)

          # @sg-ignore
          # @type [Date]
          before = Date.today + value + 1

          [{ "#{API_PREFIX.fetch(prefix)}.before" => before.to_s }, []]
        end

        # @param param_key [String]
        # @return [String]
        def get_single_param(param_key)
          raise "Expected #{param_key} to have at least one value" unless date_url_params.key? param_key

          value = date_url_params.fetch(param_key)

          raise "Expected #{param_key} to have one value" if value.length != 1

          value[0]
        end

        # @param prefix [String]
        # @return [void]
        def validate_unit_not_provided!(prefix)
          return unless date_url_params.key? "#{prefix}.unit"

          raise "Teach me how to handle other #{prefix}.unit for these params: #{date_url_params.inspect}"
        end

        # @param prefix [String]
        # @return [void]
        def validate_unit_is_day!(prefix)
          unit = date_url_params.fetch("#{prefix}.unit").fetch(0)

          raise "Teach me how to handle other time units: #{unit}" unless unit == 'day'
        end

        # @return [Hash{String => Array<String>}]
        attr_reader :date_url_params
      end
    end
  end
end
