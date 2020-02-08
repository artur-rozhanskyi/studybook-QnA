#!/bin/bash
# Interpreter identifier

# Exit on fail
set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

bundle exec rails assets:precompile
bundle exec rake ts:configure ts:start

exec "$@"
