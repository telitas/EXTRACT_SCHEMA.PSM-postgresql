#!/usr/bin/env bash
set -eu

script_directory=$(cd $(dirname $0); pwd)
test_root_directory=$(cd $(dirname ${script_directory}); pwd)
repos_root_directory=$(cd $(dirname ${test_root_directory}); pwd)

docker compose down --volumes
docker compose up --detach

export PGPASSFILE="${test_root_directory%/}/.pgpass"

while ! pg_isready --host localhost --port 5432 --dbname postgres --user postgres > /dev/null 2> /dev/null
do
    echo -n .
    sleep 1
done
echo
