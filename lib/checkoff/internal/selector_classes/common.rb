# typed: true
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
        # @param args [Array<Object>]
        # @return [Boolean]
        def evaluate(_resource, *args)
          args.any? { |arg| arg }
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
          # @sg-ignore needs-yard-annotation
          #   resource_custom_field_by_name declares a bare Hash return; bracket access below can't be typed
          custom_field = @custom_fields.resource_custom_field_by_name(resource, custom_field_name)
          # @sg-ignore needs-yard-annotation
          #   same bare-Hash gap cascading through the nil check
          return nil if custom_field.nil?

          # @sg-ignore needs-yard-annotation
          #   same bare-Hash gap; bracket access on an untyped Hash value
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

        # @sg-ignore needs-yard-annotation
        #   resource_custom_field_by_gid_or_raise declares a bare Hash return
        # @param resource [Asana::Resources::Task,Asana::Resources::Project]
        # @sg-ignore needs-yard-annotation
        #   same bare-Hash gap
        # @param custom_field_gid [String]
        # @return [String, nil]
        # @sg-ignore needs-yard-annotation
        #   same bare-Hash gap
        def evaluate(resource, custom_field_gid)
          # @sg-ignore needs-yard-annotation
          #   resource_custom_field_by_gid_or_raise declares a bare Hash return
          custom_field = @custom_fields.resource_custom_field_by_gid_or_raise(resource, custom_field_gid)
          # @sg-ignore needs-yard-annotation
          #   bracket access on the same untyped Hash value
          custom_field['display_value']
        end
      end

      # :custom_field_gid_value_contains_any_gid? function
      class CustomFieldGidValueContainsAnyGidPFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :custom_field_gid_value_contains_any_gid?

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        def evaluate_arg?(_index)
          false
        end

        # @param resource [Asana::Resources::Task,Asana::Resources::Project]
        # @sg-ignore needs-yard-annotation
        #   resource_custom_field_values_gids_or_raise's Array<String> element type doesn't
        #   propagate to the @return below
        # @param custom_field_gid [String]
        # @param custom_field_values_gids [Array<String>]
        # @return [Boolean]
        # @sg-ignore needs-yard-annotation
        #   same propagation gap
        def evaluate(resource, custom_field_gid, custom_field_values_gids)
          # @sg-ignore needs-yard-annotation
          #   resource_custom_field_values_gids_or_raise's declared type doesn't reach this local
          actual_custom_field_values_gids = @custom_fields.resource_custom_field_values_gids_or_raise(resource,
                                                                                                      custom_field_gid)

          # @sg-ignore needs-yard-annotation
          #   same declared-type propagation gap on #intersect?
          actual_custom_field_values_gids.intersect?(custom_field_values_gids)
        end
      end

      # :custom_field_value_contains_any_value?
      class CustomFieldValueContainsAnyValuePFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :custom_field_value_contains_any_value?

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        def evaluate_arg?(_index)
          false
        end

        # @param resource [Asana::Resources::Task,Asana::Resources::Project]
        # @param custom_field_name [String]
        # @sg-ignore needs-yard-annotation
        #   resource_custom_field_values_names_by_name's declared Array<String> doesn't match the
        #   inferred type below (see custom_fields.rb's own annotated ignore on that method)
        # @param custom_field_value_names [Array<String>]
        # @sg-ignore needs-yard-annotation
        #   same declared-vs-inferred mismatch
        # @return [Boolean]
        def evaluate(resource, custom_field_name, custom_field_value_names)
          actual_custom_field_values_names =
            # @sg-ignore needs-yard-annotation
            #   resource_custom_field_values_names_by_name's declared Array<String> doesn't match
            #   the inferred type here
            @custom_fields.resource_custom_field_values_names_by_name(resource,
                                                                      custom_field_name)

          # @sg-ignore needs-yard-annotation
          #   same declared-vs-inferred mismatch on #intersect?
          actual_custom_field_values_names.intersect?(custom_field_value_names)
        end
      end

      # :custom_field_gid_value_contains_all_gids? function
      class CustomFieldGidValueContainsAllGidsPFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :custom_field_gid_value_contains_all_gids?

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
            # @sg-ignore needs-yard-annotation
            #   resource_custom_field_values_gids_or_raise's declared type doesn't reach this local
            @custom_fields.resource_custom_field_values_gids_or_raise(resource,
                                                                      custom_field_gid)

          custom_field_values_gids.all? do |custom_field_value|
            # @sg-ignore needs-yard-annotation
            #   same declared-type propagation gap on #include?
            actual_custom_field_values_gids.include?(custom_field_value)
          end
        end
      end

      # :name_starts_with? function
      class NameStartsWithPFunctionEvaluator < FunctionEvaluator
        FUNCTION_NAME = :name_starts_with?

        def matches?
          fn?(selector, FUNCTION_NAME)
        end

        def evaluate_arg?(_index)
          false
        end

        # @param resource [Asana::Resources::Task, Asana::Resources::Project]
        # @param prefix [String]
        # @return [boolish]
        # @sg-ignore dynamic-metaprogramming
        #   Checkoff::SelectorClasses::Common::NameStartsWithPFunctionEvaluator#evaluate return
        #   type could not be inferred — resource.name is dispatched via the asana gem's
        #   method_missing, so &.start_with? chains off an untyped receiver
        def evaluate(resource, prefix)
          resource.name&.start_with?(prefix)
        end
      end

      # String literals
      class StringLiteralEvaluator < FunctionEvaluator
        def matches?
          selector.is_a?(String)
        end

        # @param _resource [Asana::Resources::Task,Asana::Resources::Project]
        # @return [String]
        # @sg-ignore tool-limitation:return-type-didnt-stick
        #   T.cast(selector, String) as the tail expression still isn't recognized as satisfying
        #   the declared @return [String]
        def evaluate(_resource)
          T.cast(selector, String)
        end
      end
    end
  end
end
