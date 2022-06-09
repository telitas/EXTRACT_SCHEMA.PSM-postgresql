#!/usr/bin/env bash
set -eu

script_directory=$(cd $(dirname $0); pwd)
test_root_directory=$(cd $(dirname ${script_directory}); pwd)
output_directory="${script_directory}/schema"

if [[ ! -e $output_directory ]]; then
    mkdir -p $output_directory
fi

export PGPASSFILE="${test_root_directory%/}/.pgpass"

schema_name="pgschema"
for file in `ls ${test_root_directory%/}/initdb/*_${schema_name}_*.sql`
do
    table_name=$(echo $(basename $file) | sed -E "s/^[0-9]+_${schema_name}_([^.]+).sql$/\1/g")
    psql --host localhost --port 5432 --dbname postgres --user postgres --tuples-only --command "SELECT ${schema_name}.extract_table_as_json('${table_name}', '${schema_name}');" \
    | jq > "${output_directory%/}/${table_name}.json"
done
