# frozen_string_literal: true

require 'asana'

# Monkeypatches Asana::Resources::Resource so that Ruby marshalling and
# unmarshalling works on Asana resource classes.  Currently, it will
# work unless you call an accessor method, which triggers Asana's
# client library Resource class' method_missing() to "cache" the
# result by creating a singleton method.  Unfortunately, singleton
# methods break marshalling, which is not smart enough to know that it
# is not necessary to marshall them as they will simply be recreated
# when needed.

module Asana
  # Monkeypatches:
  #
  # https://github.com/Asana/ruby-asana/blob/master/lib/asana
  module Resources
    # Public: The base resource class which provides some sugar over common
    # resource functionality.
    class Resource
      # @return [Hash]
      def marshal_dump
        { 'data' => @_data,
          'client' => @_client }
      end

      # @param data [Hash]
      #
      # @return [void]
      def marshal_load(data)
        # @sg-ignore
        # @type [Asana::Client]
        @_client = data.fetch('client')
        # @sg-ignore
        # @type [Hash]
        @_data = data.fetch('data')
        @_data.each do |k, v|
          if respond_to?(k)
            variable = :"@#{k}"
            instance_variable_set(variable, v)
          end
        end
      end
    end
  end
end
