#!/usr/bin/env bash

# This needs to be run in the build tree, which is normally ray/build

# Cause the script to exit if a single command fails.
set -e

# Start the Redis shards.
./src/common/thirdparty/redis/src/redis-server --loglevel warning --loadmodule ./src/common/redis_module/libray_redis_module.so --port 6379 &
./src/common/thirdparty/redis/src/redis-server --loglevel warning --loadmodule ./src/common/redis_module/libray_redis_module.so --port 6380 &
sleep 1s
# Register the shard location with the primary shard.
./src/common/thirdparty/redis/src/redis-cli set NumRedisShards 1
./src/common/thirdparty/redis/src/redis-cli rpush RedisShards 127.0.0.1:6380

valgrind --leak-check=full --error-exitcode=1 ./src/common/common_tests
valgrind --leak-check=full --error-exitcode=1 ./src/common/db_tests
valgrind --leak-check=full --error-exitcode=1 ./src/common/io_tests
valgrind --leak-check=full --error-exitcode=1 ./src/common/task_tests
valgrind --leak-check=full --error-exitcode=1 ./src/common/redis_tests
valgrind --leak-check=full --error-exitcode=1 ./src/common/task_table_tests
valgrind --leak-check=full --error-exitcode=1 ./src/common/object_table_tests

./src/common/thirdparty/redis/src/redis-cli shutdown
./src/common/thirdparty/redis/src/redis-cli -p 6380 shutdown
