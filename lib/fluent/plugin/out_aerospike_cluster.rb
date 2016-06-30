module Fluent
  class AerospikeClusterOutput < BufferedOutput
    Fluent::Plugin.register_output('aerospike_cluster', self)
    include Fluent::SetTagKeyMixin
    config_set_default :include_tag_key, false

    include Fluent::SetTimeKeyMixin
    config_set_default :include_time_key, true

    config_param :hosts, :string, :default => '127.0.0.1:3000',
                 :desc => "Aerospike host:port list. (comma separated)"
    config_param :username, :string, :default => nil,
                 :desc => "Aerospike username. (not implemented yet)"
    config_param :password, :string, :default => nil,
                 :desc => "Aerospike password. (not implemented yet)"
    config_param :timeout, :float, :default => 1.0,
                 :desc => "Connection timeout second."
    config_param :connection_queue_size, :integer, :default => 64,
                 :desc => "Size of the connection queue cache."
    config_param :tend_interval, :float, :default => 1000,
                 :desc => "Tend interval in milliseconds; determines the interval at which the client checks for cluster state changes. Minimum interval is 10ms."
    config_param :namespace, :string,
                 :desc => "Aerospike namespace."
    config_param :set, :string,
                 :desc => "Aerospike set."
    config_param :keys, :string,
                 :desc => "Keys for key of record."
    config_param :record_keys, :string,
                 :desc => "Keys for record values. (comma separated)"
    config_param :send_key, :bool, :default => true,
                 :desc => "Send user defined key in addition to hash digest on a record put."
    config_param :ttl, :integer, :default => 0,
                 :desc => "Record ttl seconds. (-1: never expire, 0: default namespace's ttl)"
    config_param :record_exists_action, :string, :default => nil,
                 :desc => <<DESC
Qualify how to handle writes where the record already exists.
update update_only replace replace_only
DESC
    attr_accessor :client_policy, :write_policy

    def configure(conf)
      super
      @hosts = @hosts.split(/\s*,\s*/).map {|host|
        host = host.split(":")
        Aerospike::Host.new(host[0], host[1].nil? ? 3000 : host[1].to_i)
      }
      @client_policy = Aerospike::ClientPolicy.new({
        :user                  => @username,
        :password              => @password,
        :timeout               => @timeout,
        :connection_queue_size => @connection_queue_size,
        :tend_interval         => @tend_interval
      })
      @write_policy = Aerospike::WritePolicy.new({
        :record_exists_action  => @record_exists_action.nil? ? nil : Aerospike::RecordExistsAction.const_get(@record_exists_action.upcase.to_sym),
        :generation_policy     => nil,
        :generation            => nil,
        :ttl                   => @ttl,
        :send_key              => @send_key,
        :commit_level          => nil
      })
      @keys = @keys.split(/\s*,\s*/)
      @record_keys = @record_keys.split(/\s*,\s*/)
    end

    def initialize
      super
      require 'aerospike'
    end

    # Define `log` method for v0.10.42 or earlier
    unless method_defined?(:log)
      define_method("log") { $log }
    end

    def client
      @handler ||= Aerospike::Client.new(@hosts, policy: @client_policy)
    end

    def start
      super
      client
    end

    def shutdown
      @handler.close
      super
    end

    def format(tag, time, record)
      [tag, time, record].to_msgpack
    end

    def write(chunk)
      log.debug "<<<<<<<<<<<<<<{Aerospike write chunk}<<<<<<<<<<<<<"
      chunk.msgpack_each do |tag, time, record|
        # Key
        if @keys.length == 1
          key = Aerospike::Key.new(@namespace, @set, record[@keys[0]])
        else
          key = Aerospike::Key.new(@namespace, @set, @keys.map {|col| record[col]})
        end
        # Value
        if @record_keys.length > 0
          record = record.select {|key, _| @record_keys.include? key }
        end

        log.debug "key:   #{key.to_s}"
        log.debug "value: #{record.to_s}"
        @handler.put(key, record, @write_policy)
      end
      log.debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    end
  end
end
