#!/usr/bin/env bash

BIN="${BASH_SOURCE-$0}"
BIN="$(dirname "${BIN}")"
BASEDIR="$(cd "${BIN}/.."; pwd)"

docker-compose up -d

./bin/update_docker_hosts.sh
