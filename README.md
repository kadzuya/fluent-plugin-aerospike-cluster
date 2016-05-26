# fluent-plugin-aerospike-cluster

fluent output plugin for aerospike.


## Parameters

param                | type     | value                                                              | default
---------------------|----------|--------------------------------------------------------------------|---------------
hosts                | string   | Aerospike host:port list. (comma separated)                        | 127.0.0.1:3000
username             | string   | Aerospike username. (not implemented yet)                          |
password             | string   | Aerospike password. (not implemented yet)                          |
timeout              | float    | Connection timeout second.                                         | 1.0
connection_queue_size| integer  | Size of the connection queue cache.                                | 64
tend_interval        | float    | Tend interval in milliseconds; determines the                      interval at which the client checks for cluster state changes. Minimum interval is 10ms.  | 1000
namespace            | string   | Aerospike namespace.                                               |
set                  | string   | Aerospike set.                                                     |
keys                 | string   | Keys for key of record.                                            |
record_keys          | string   | Keys for Record values. (comma separated)                          |
send_key             | bool     | Send user defined key in addition to hash digest on a record put.  | true
ttl                  | integer  | Record ttl seconds. (-1: never expire, 0: default namespace's ttl) | 0
record_exists_action | string   | Qualify how to handle writes where the record already exists.  update update_only replace replace_only  |

## Another Parameters

- include_tag_key
- tag_key
- include_time_key
- time_key

