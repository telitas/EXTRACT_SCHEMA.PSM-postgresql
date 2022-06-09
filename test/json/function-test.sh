#!/usr/bin/env bash
set -eu

script_directory=$(cd $(dirname $0); pwd)
test_root_directory=$(cd $(dirname ${script_directory}); pwd)
repos_root_directory=$(cd $(dirname ${test_root_directory}); pwd)

export PGPASSFILE="${test_root_directory%/}/.pgpass"

psql --host localhost --port 5432 --dbname postgres --user postgres --tuples-only << EOS
SET search_path TO pgschema;
$(cat "${repos_root_directory%/}/src/extract_table_as_json.sql")
EOS

pg_prove --host localhost --port 5432 --dbname postgres --username pguser "${script_directory%/}/t"
exit $?
