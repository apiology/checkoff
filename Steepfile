# frozen_string_literal: true

target :lib do
  signature 'sig', 'tmp-stubs'

  check 'lib'

  collection_config 'rbs_collection.yaml'

  %w[cgi date forwardable json logger net-http openssl tempfile time
     uri yaml].each { |lib| library lib }
end
