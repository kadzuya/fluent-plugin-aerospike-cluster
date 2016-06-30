$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'fluent/test'
require 'fluent/plugin/out_aerospike_cluster'

Test::Unit.run = true if defined?(Test::Unit) && Test::Unit.respond_to?(:run=)

