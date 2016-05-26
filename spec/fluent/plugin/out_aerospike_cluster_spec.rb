require 'spec_helper'
require 'pp'

describe Fluent::AerospikeClusterOutput do
  before(:all) { Fluent::Test.setup }
  let(:driver) {
    #Fluent::Test::BufferedOutputTestDriver.new(Fluent::AerospikeClusterOutput, tag).configure(config)
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::AerospikeClusterOutput).configure(config)
  }

  describe 'configure' do
    context 'when without hosts' do
      let(:config) { %[
namespace test
set set
keys some_key
record_keys some_value_key
      ] }
      it 'can uses default hosts 127.0.0.1:3000' do
        expect(driver.instance.hosts.length).to eq(1)
        expect(driver.instance.hosts[0]).to eq(Aerospike::Host.new('127.0.0.1', 3000))
      end
    end

    context 'when without namespace' do
      let(:config) { %[
set set
keys some_key
record_keys some_value_key
      ] }
      it 'raise exception' do
        expect { driver }.to raise_exception(Fluent::ConfigError)
      end
    end

    context 'when without set' do
      let(:config) { %[
namespace test
keys some_key
record_keys some_value_key
      ] }
      it 'raise exception' do
        expect { driver }.to raise_exception(Fluent::ConfigError)
      end
    end


    context 'when without keys' do
      let(:config) { %[
namespace test
set set
record_keys some_value_key
      ] }
      it 'raise exception' do
        expect { driver }.to raise_exception(Fluent::ConfigError)
      end
    end

    context 'when without record_keys' do
      let(:config) { %[
namespace test
set set
keys some_key
      ] }
      it 'raise exception' do
        expect { driver }.to raise_exception(Fluent::ConfigError)
      end
    end

    context 'when minimum config' do
      let(:config) { %[
hosts localhost:3001
namespace test
set set
keys some_key
record_keys some_value_key
      ] }
      it 'can parse single host in hosts' do
        expect(driver.instance.hosts.length).to eq(1)
        expect(driver.instance.hosts[0]).to eq(Aerospike::Host.new('localhost', 3001))
      end
      it 'can parse single key in keys' do
        expect(driver.instance.keys).to eq(['some_key'])
      end
      it 'can parse single key in value_key' do
        expect(driver.instance.record_keys).to eq(['some_value_key'])
      end
    end

    context 'when multiple value in one config field' do
      let(:config) { %[
hosts localhost:3001,111.111.111.111:13001,222.222.222.222:22222
namespace test
set set
keys some_first_key,some_second_key
record_keys some_first_value_key,some_second_value_key
      ] }
      it 'can parse multiple host in hosts' do
        expect(driver.instance.hosts.length).to eq(3)
        expect(driver.instance.hosts).to eq([
          Aerospike::Host.new('localhost', 3001),
          Aerospike::Host.new('111.111.111.111', 13001),
          Aerospike::Host.new('222.222.222.222', 22222)
        ])
      end
      it 'can parse multiple keys in keys' do
        expect(driver.instance.keys).to eq(['some_first_key', 'some_second_key'])
      end
      it 'can parse multiple keys in record_keys' do
        expect(driver.instance.record_keys).to eq(['some_first_value_key','some_second_value_key'])
      end
    end

    context 'when multiple value with spaces in one config field' do
      let(:config) { %[
hosts   localhost:3001, 111.111.111.111:13001 ,  222.222.222.222:22222  
namespace test
set set
keys some_first_key, some_second_key,  some_third_key
record_keys  some_first_value_key, some_second_value_key  ,  some_third_value_key
      ] }
      it 'can parse multiple host in hosts' do
        expect(driver.instance.hosts.length).to eq(3)
        expect(driver.instance.hosts).to eq([
          Aerospike::Host.new('localhost', 3001),
          Aerospike::Host.new('111.111.111.111', 13001),
          Aerospike::Host.new('222.222.222.222', 22222)
        ])
      end
      it 'can parse multiple keys in keys' do
        expect(driver.instance.keys).to eq(['some_first_key', 'some_second_key', 'some_third_key'])
      end
      it 'can parse multiple keys in record_keys' do
        expect(driver.instance.record_keys).to eq(['some_first_value_key','some_second_value_key','some_third_value_key'])
      end
    end

    context 'when full config' do
      let(:config) { %[
hosts   localhost:3001, 111.111.111.111:13001
username usr
password psswd
timeout 1.2
connection_queue_size 23
tend_interval 456
namespace test_ns
set test_set
keys some_first_key, some_second_key
record_keys some_first_value_key, some_second_value_key
send_key false
ttl 789
record_exists_action replace_only
      ] }
      it 'can parse' do
        expect(driver.instance.hosts).to eq([
          Aerospike::Host.new('localhost', 3001),
          Aerospike::Host.new('111.111.111.111', 13001),
        ])
        expect(driver.instance.client_policy.user).to eq('usr')
        expect(driver.instance.client_policy.password).to eq('psswd')
        expect(driver.instance.client_policy.timeout).to eq(1.2)
        expect(driver.instance.client_policy.connection_queue_size).to eq(23)
        expect(driver.instance.client_policy.tend_interval).to eq(456)
        expect(driver.instance.namespace).to eq('test_ns')
        expect(driver.instance.set).to eq('test_set')
        expect(driver.instance.keys).to eq(['some_first_key', 'some_second_key'])
        expect(driver.instance.record_keys).to eq(['some_first_value_key','some_second_value_key'])
        expect(driver.instance.write_policy.send_key).to eq(false)
        expect(driver.instance.write_policy.expiration).to eq(789)
        expect(driver.instance.write_policy.record_exists_action).to eq(Aerospike::RecordExistsAction::REPLACE_ONLY)
      end
    end
  end
end
