# frozen_string_literal: true

require_relative 'common/function_evaluator'

module Checkoff
  module SelectorClasses
    module Common
      # :and function
      class AndFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :and

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        # @param _resource [Asana::Resources::Task,Asana::Resources::Project]
        # @param args [Array<Object>]
        # @return [Boolean]
        def evaluate(_resource, *args)
          args.all? { |arg| arg }
        end
      end

      # :or function
      #
      # Does not yet shortcut, but may in future - be careful with side
      # effects!
      class OrFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :or

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        # @param _resource [Asana::Resources::Task,Asana::Resources::Project]
        # @param lhs [Object]
        # @param rhs [Object]
        # @return [Object]
        def evaluate(_resource, lhs, rhs)
          lhs || rhs
        end
      end

      # :not function
      class NotFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :not

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        # @param _resource [Asana::Resources::Task,Asana::Resources::Project]
        # @param subvalue [Object]
        # @return [Boolean]
        def evaluate(_resource, subvalue)
          !subvalue
        end
      end

      # :nil? function
      class NilPFunctionEvaluator < FunctionEvaluator
        def matches?
          fn?(selector, :nil?)
        end

        # @param _resource [Asana::Resources::Task,Asana::Resources::Project]
        # @param subvalue [Object]
        # @return [Boolean]
        def evaluate(_resource, subvalue)
          subvalue.nil?
        end
      end

      # :equals? function
      class EqualsPFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :equals?

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        # @param _resource [Asana::Resources::Task,Asana::Resources::Project]
        # @param lhs [Object]
        # @param rhs [Object]
        # @return [Boolean]
        def evaluate(_resource, lhs, rhs)
          lhs == rhs
        end
      end

      # :custom_field_value function
      class CustomFieldValueFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :custom_field_value

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        # @param _index [Integer]
        def evaluate_arg?(_index)
          false
        end

        # @param resource [Asana::Resources::Task,Asana::Resources::Project]
        # @param custom_field_name [String]
        # @return [String, nil]
        def evaluate(resource, custom_field_name)
          custom_field = @custom_fields.resource_custom_field_by_name(resource, custom_field_name)
          return nil if custom_field.nil?

          custom_field['display_value']
        end
      end

      # :custom_field_gid_value function
      class CustomFieldGidValueFunctionEvaluator < FunctionEvaluator
        def matches?
          fn?(selector, :custom_field_gid_value)
        end

        def evaluate_arg?(_index)
          false
        end

        # @sg-ignore
        # @param resource [Asana::Resources::Task,Asana::Resources::Project]
        # @param custom_field_gid [String]
        # @return [String, nil]
        def evaluate(resource, custom_field_gid)
          custom_field = @custom_fields.resource_custom_field_by_gid_or_raise(resource, custom_field_gid)
          custom_field['display_value']
        end
      end

      # :custom_field_gid_value_contains_any_gid function
      class CustomFieldGidValueContainsAnyGidFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :custom_field_gid_value_contains_any_gid

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        def evaluate_arg?(_index)
          false
        end

        # @param resource [Asana::Resources::Task,Asana::Resources::Project]
        # @param custom_field_gid [String]
        # @param custom_field_values_gids [Array<String>]
        # @return [Boolean]
        def evaluate(resource, custom_field_gid, custom_field_values_gids)
          actual_custom_field_values_gids = @custom_fields.resource_custom_field_values_gids_or_raise(resource,
                                                                                                      custom_field_gid)

          actual_custom_field_values_gids.any? do |custom_field_value|
            custom_field_values_gids.include?(custom_field_value)
          end
        end
      end

      # :custom_field_value_contains_any_value
      class CustomFieldValueContainsAnyValueFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :custom_field_value_contains_any_value

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        def evaluate_arg?(_index)
          false
        end

        # @param resource [Asana::Resources::Task,Asana::Resources::Project]
        # @param custom_field_name [String]
        # @param custom_field_value_names [Array<String>]
        # @return [Boolean]
        def evaluate(resource, custom_field_name, custom_field_value_names)
          actual_custom_field_values_names =
            @custom_fields.resource_custom_field_values_names_by_name(resource,
                                                                      custom_field_name)

          actual_custom_field_values_names.any? do |custom_field_value|
            custom_field_value_names.include?(custom_field_value)
          end
        end
      end

      # :custom_field_gid_value_contains_all_gids function
      class CustomFieldGidValueContainsAllGidsFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :custom_field_gid_value_contains_all_gids

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        def evaluate_arg?(_index)
          false
        end

        # @param resource [Asana::Resources::Task,Asana::Resources::Project]
        # @param custom_field_gid [String]
        # @param custom_field_values_gids [Array<String>]
        # @return [Boolean]
        def evaluate(resource, custom_field_gid, custom_field_values_gids)
          actual_custom_field_values_gids =
            @custom_fields.resource_custom_field_values_gids_or_raise(resource,
                                                                      custom_field_gid)

          custom_field_values_gids.all? do |custom_field_value|
            actual_custom_field_values_gids.include?(custom_field_value)
          end
        end
      end

      # String literals
      class StringLiteralEvaluator < FunctionEvaluator
        def matches?
          selector.is_a?(String)
        end

        # @sg-ignore
        # @param _resource [Asana::Resources::Task,Asana::Resources::Project]
        # @return [String]
        def evaluate(_resource)
          selector
        end
      end
    end
  end
end
