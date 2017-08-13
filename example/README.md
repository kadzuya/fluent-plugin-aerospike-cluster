Running Example
================

```
$ docker-compose up -d
$ docker-compose exec fluentd sh -c "echo '{\"key1\":\"foo\",\"val1\":\"bar\",\"val2\":\"baz\"}' | fluent-cat test"
$ docker-compose exec aerospike1 aql -c 'SELECT * FROM test.test_set'
$ docker logs example_fluentd_1
```

