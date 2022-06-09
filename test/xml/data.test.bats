#!/usr/bin/env bats

setup() {
    cd $BATS_TEST_DIRNAME
}

# sample_table

@test "sample_table.xsd validate no_records.xml -> valid" {
    xmllint --noout --schema ./schema/sample_table.xsd ./data/sample_table/valid/no_records.xml
}

@test "sample_table.xsd validate valid_values.xml -> valid" {
    xmllint --noout --schema ./schema/sample_table.xsd ./data/sample_table/valid/valid_values.xml
}

# all_types_table

@test "all_types_table.xsd validate valid_values.xml -> valid" {
    xmllint --noout --schema ./schema/all_types_table.xsd ./data/all_types_table/valid/valid_values.xml
}

@test "all_types_table.xsd validate time_with_time_zone_without_time_zone.xml -> invalid" {
    set +e
    xmllint --noout --schema ./schema/all_types_table.xsd ./data/all_types_table/invalid/time_with_time_zone_without_time_zone.xml
    result=$?
    set -e
    [ $result -ne 0 ]
}

@test "all_types_table.xsd validate time_without_time_zone_with_time_zone.xml -> invalid" {
    set +e
    xmllint --noout --schema ./schema/all_types_table.xsd ./data/all_types_table/invalid/time_without_time_zone_with_time_zone.xml
    result=$?
    set -e
    [ $result -ne 0 ]
}

@test "all_types_table.xsd validate time_without_time_zone_with_utc.xml -> invalid" {
    set +e
    xmllint --noout --schema ./schema/all_types_table.xsd ./data/all_types_table/invalid/time_without_time_zone_with_utc.xml
    result=$?
    set -e
    [ $result -ne 0 ]
}

@test "all_types_table.xsd validate timestamp_with_time_zone_without_time_zone.xml -> invalid" {
    set +e
    xmllint --noout --schema ./schema/all_types_table.xsd ./data/all_types_table/invalid/timestamp_with_time_zone_without_time_zone.xml
    result=$?
    set -e
    [ $result -ne 0 ]
}

@test "all_types_table.xsd validate timestamp_without_time_zone_with_time_zone.xml -> invalid" {
    set +e
    xmllint --noout --schema ./schema/all_types_table.xsd ./data/all_types_table/invalid/timestamp_without_time_zone_with_time_zone.xml
    result=$?
    set -e
    [ $result -ne 0 ]
}

@test "all_types_table.xsd validate timestamp_without_time_zone_with_utc.xml -> invalid" {
    set +e
    xmllint --noout --schema ./schema/all_types_table.xsd ./data/all_types_table/invalid/timestamp_without_time_zone_with_utc.xml
    result=$?
    set -e
    [ $result -ne 0 ]
}

# notnull_table

@test "notnull_table.xsd validate valid_values.xml -> valid" {
    xmllint --noout --schema ./schema/notnull_table.xsd ./data/notnull_table/valid/valid_values.xml
}

@test "notnull_table.xsd validate null_column.xml -> invalid" {
    set +e
    xmllint --noout --schema ./schema/notnull_table.xsd ./data/notnull_table/invalid/null_column.xml
    result=$?
    set -e
    [ $result -ne 0 ]
}

@test "notnull_table.xsd validate omit_column.xml -> invalid" {
    set +e
    xmllint --noout --schema ./schema/notnull_table.xsd ./data/notnull_table/invalid/omit_column.xml
    result=$?
    set -e
    [ $result -ne 0 ]
}

# single_column_key_table

@test "single_column_key_table.xsd validate valid_values.xml -> valid" {
    xmllint --noout --schema ./schema/single_column_key_table.xsd ./data/single_column_key_table/valid/valid_values.xml
}

@test "single_column_key_table.xsd validate duplicate_rows.xml -> valid" {
    set +e
    xmllint --noout --schema ./schema/single_column_key_table.xsd ./data/single_column_key_table/invalid/duplicate_rows.xml
    result=$?
    set -e
    [ $result -ne 0 ]
}

@test "single_column_key_table.xsd validate null_column.xml -> invalid" {
    set +e
    xmllint --noout --schema ./schema/single_column_key_table.xsd ./data/single_column_key_table/invalid/null_column.xml
    result=$?
    set -e
    [ $result -ne 0 ]
}

@test "single_column_key_table.xsd validate omit_column.xml -> invalid" {
    set +e
    xmllint --noout --schema ./schema/single_column_key_table.xsd ./data/single_column_key_table/invalid/omit_column.xml
    result=$?
    set -e
    [ $result -ne 0 ]
}

# multiple_columns_key_table

@test "multiple_columns_key_table.xsd validate valid_values.xml -> valid" {
    xmllint --noout --schema ./schema/multiple_columns_key_table.xsd ./data/multiple_columns_key_table/valid/valid_values.xml
}

@test "multiple_columns_key_table.xsd validate duplicate_rows.xml -> valid" {
    xmllint --noout --schema ./schema/multiple_columns_key_table.xsd ./data/multiple_columns_key_table/valid/duplicate_rows.xml
}

@test "multiple_columns_key_table.xsd validate null_column.xml -> invalid" {
    set +e
    xmllint --noout --schema ./schema/multiple_columns_key_table.xsd ./data/multiple_columns_key_table/invalid/null_column.xml
    result=$?
    set -e
    [ $result -ne 0 ]
}

@test "multiple_columns_key_table.xsd validate omit_column.xml -> invalid" {
    set +e
    xmllint --noout --schema ./schema/multiple_columns_key_table.xsd ./data/multiple_columns_key_table/invalid/omit_column.xml
    result=$?
    set -e
    [ $result -ne 0 ]
}

# single_column_unique_table

# @test "single_column_unique_table.xsd validate valid_values.xml -> valid" {
#     xmllint --noout --schema ./schema/single_column_unique_table.xsd ./data/single_column_unique_table/valid/valid_values.xml
# }

@test "single_column_unique_table.xsd validate duplicate_rows.xml -> valid" {
    set +e
    xmllint --noout --schema ./schema/single_column_unique_table.xsd ./data/single_column_unique_table/invalid/duplicate_rows.xml
    result=$?
    set -e
    [ $result -ne 0 ]
}

# multiple_columns_unique_table

@test "multiple_columns_unique_table.xsd validate valid_values.xml -> valid" {
    xmllint --noout --schema ./schema/multiple_columns_unique_table.xsd ./data/multiple_columns_unique_table/valid/valid_values.xml
}

@test "multiple_columns_unique_table.xsd validate duplicate_rows.xml -> valid" {
    xmllint --noout --schema ./schema/multiple_columns_unique_table.xsd ./data/multiple_columns_unique_table/valid/duplicate_rows.xml
}

# numeric_scale_table

@test "numeric_scale_table.xsd validate valid_values.xml -> valid" {
    xmllint --noout --schema ./schema/numeric_scale_table.xsd ./data/numeric_scale_table/valid/valid_values.xml
}

# sample_view

@test "sample_view.xsd validate valid_values.xml -> valid" {
    xmllint --noout --schema ./schema/sample_view.xsd ./data/sample_table/valid/valid_values.xml
}

# literal_view

@test "literal_view.xsd validate valid_values.xml -> valid" {
    xmllint --noout --schema ./schema/literal_view.xsd ./data/literal_view/valid/valid_values.xml
}
