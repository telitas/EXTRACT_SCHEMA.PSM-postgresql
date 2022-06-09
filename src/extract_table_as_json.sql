CREATE OR REPLACE FUNCTION extract_table_as_json(table_name CHARACTER VARYING, schema_name CHARACTER VARYING DEFAULT current_schema()) RETURNS JSON AS $extract_table_as_json$
DECLARE
/**
DESCRIPTION:
    Extract the table schema as JSON.(preview)
    
    This function is a preview.
    That is because JSON Schema is in draft.
    
PARAM: table_name CHARACTER VARYING
    Target table name to extract the schema as JSON.
    
PARAM: schema_name CHARACTER VARYING (DEFAULT: invoker current schema)
    The name of the schema to search for the table.
    
RETURN: JSON
    Generated JSON Schema document.
    If the table is not found, it will be NULL.
    
VERSION: ${version}
    
LAST UPDATE: ${last_update}
    
LICENSE:
    Copyright (c) 2022 telitas
    This function is released under the MIT License.
    See the LICENSE.txt file or https://opensource.org/licenses/mit-license.php for details.
*/
    generated_document JSON;
BEGIN
    RAISE DEBUG 'table_name=%, schema_name=%', table_name, schema_name;
    
    WITH target_table(table_schema, table_name) AS (
        SELECT
            tbl.table_schema,
            tbl.table_name
        FROM information_schema.tables AS tbl
        WHERE
			    tbl.table_schema = extract_table_as_json.schema_name
			AND tbl.table_name = extract_table_as_json.table_name
    ),
    target_table_columns(ordinal_position, column_name, data_type, is_nullable, character_maximum_length, character_octet_length, numeric_precision, numeric_scale) AS (
        SELECT
            col.ordinal_position,
            col.column_name,
            col.data_type,
            col.is_nullable = 'YES',
            col.character_maximum_length,
            col.character_octet_length,
            col.numeric_precision,
            col.numeric_scale
        FROM target_table AS tbl
            INNER JOIN information_schema.columns AS col ON
                    tbl.table_schema = col.table_schema
                AND tbl.table_name = col.table_name
        ORDER BY ordinal_position
    ),
    target_table_constraints(constraint_name, constraint_type, columns_count, ordinal_position, column_name) AS (
		SELECT
			con.constraint_name,
			con.constraint_type,
            COUNT(*) OVER(PARTITION BY con.constraint_name),
			keycol.ordinal_position,
			keycol.column_name
		FROM target_table AS tbl
			INNER JOIN information_schema.table_constraints AS con ON
					tbl.table_schema = con.table_schema
				AND tbl.table_name = con.table_name
			INNER JOIN information_schema.key_column_usage AS keycol ON
					con.constraint_schema = keycol.constraint_schema
				AND con.constraint_name = keycol.constraint_name
    ),
    row_section(document) AS (
        SELECT json_object_agg(col.column_name,
            CASE col.data_type
                WHEN 'numeric' THEN
                    json_build_object(
                        'type', CASE WHEN col.is_nullable THEN json_build_array('string', 'null') ELSE to_json('string'::text) END,
                        'pattern', CASE
                            WHEN col.numeric_precision IS NULL THEN
                                '^-?(?:[0-9]+(?:\.[0-9]*)?|\.[0-9]+)$'
                            WHEN col.numeric_scale = 0 THEN
                                '^-?(?:0*[0-9]{1,' || col.numeric_precision - col.numeric_scale || '}(?:\.0*)?|\.0+)$'
                            WHEN col.numeric_precision = col.numeric_scale THEN
                                '^-?(?:0+(?:\.[0-9]{0,' || col.numeric_scale || '}0*)?|\.[0-9]{1,' || col.numeric_scale || '}0*)$'
                            ELSE
                                '^-?(?:0*[0-9]{1,' || col.numeric_precision - col.numeric_scale || '}(?:\.[0-9]{0,' || col.numeric_scale || '}0*)?|\.[0-9]{1,' || col.numeric_scale || '}0*)$'
                        END
                    )
                WHEN 'smallint' THEN
                    json_build_object(
                        'type', CASE WHEN col.is_nullable THEN json_build_array('integer', 'null') ELSE to_json('integer'::text) END,
                        'minimum', -32768,
                        'maximum', 32767
                    )
                WHEN 'integer' THEN
                    json_build_object(
                        'type', CASE WHEN col.is_nullable THEN json_build_array('integer', 'null') ELSE to_json('integer'::text) END,
                        'minimum', -2147483648,
                        'maximum', 2147483647
                    )
                WHEN 'bigint' THEN
                    json_build_object(
                        'type', CASE WHEN col.is_nullable THEN json_build_array('integer', 'null') ELSE to_json('integer'::text) END,
                        'minimum', -9223372036854775808,
                        'maximum', 9223372036854775807
                    )
                WHEN 'real' THEN
                    json_build_object(
                        'type', CASE WHEN col.is_nullable THEN json_build_array('number', 'null') ELSE to_json('number'::text) END,
                        'minimum', -3.4028235E+38,
                        'maximum', 3.4028235E+38
                    )
                WHEN 'double precision' THEN
                    json_build_object(
                        'type', CASE WHEN col.is_nullable THEN json_build_array('number', 'null') ELSE to_json('number'::text) END,
                        'minimum', -1.7976931348623157E+308,
                        'maximum', 1.7976931348623157E+308
                    )
                WHEN 'character' THEN
                    CASE
                        WHEN col.character_maximum_length > 0 THEN
                            json_build_object(
                                'type', CASE WHEN col.is_nullable THEN json_build_array('string', 'null') ELSE to_json('string'::text) END,
                                'minLength', col.character_maximum_length,
                                'maxLength', col.character_maximum_length
                            )
                        ELSE
                            json_build_object(
                                'type', CASE WHEN col.is_nullable THEN json_build_array('string', 'null') ELSE to_json('string'::text) END
                            )
                    END
                WHEN 'character varying' THEN
                    CASE
                        WHEN col.character_maximum_length > 0 THEN
                            json_build_object(
                                'type', CASE WHEN col.is_nullable THEN json_build_array('string', 'null') ELSE to_json('string'::text) END,
                                'maxLength', col.character_maximum_length
                            )
                        ELSE
                            json_build_object(
                                'type', CASE WHEN col.is_nullable THEN json_build_array('string', 'null') ELSE to_json('string'::text) END
                            )
                    END
                WHEN 'text' THEN
                    json_build_object(
                        'type', CASE WHEN col.is_nullable THEN json_build_array('string', 'null') ELSE to_json('string'::text) END
                    )
                WHEN 'bytea' THEN
                    json_build_object(
                        'type', CASE WHEN col.is_nullable THEN json_build_array('string', 'null') ELSE to_json('string'::text) END,
                        'pattern', '^(?:[0-9a-fA-F]{2})*$'
                    )
                WHEN 'boolean' THEN
                    json_build_object(
                        'type', CASE WHEN col.is_nullable THEN json_build_array('boolean', 'null') ELSE to_json('boolean'::text) END
                    )
                WHEN 'date' THEN
                    json_build_object(
                        'type', CASE WHEN col.is_nullable THEN json_build_array('string', 'null') ELSE to_json('string'::text) END,
                        'format', 'date'
                    )
                WHEN 'time without time zone' THEN
                    json_build_object(
                        'type', CASE WHEN col.is_nullable THEN json_build_array('string', 'null') ELSE to_json('string'::text) END,
                        'format', 'time',
                        'pattern', '^(?!.*([Zz]|[+-][0-9]{2}:[0-9]{2})).*$'
                    )
                WHEN 'time with time zone' THEN
                    json_build_object(
                        'type', CASE WHEN col.is_nullable THEN json_build_array('string', 'null') ELSE to_json('string'::text) END,
                        'format', 'time',
                        'pattern', '(?:[Zz]|[+-][0-9]{2}:[0-9]{2})$'
                    )
                WHEN 'timestamp without time zone' THEN
                    json_build_object(
                        'type', CASE WHEN col.is_nullable THEN json_build_array('string', 'null') ELSE to_json('string'::text) END,
                        'format', 'date-time',
                        'pattern', '^(?!.*([Zz]|[+-][0-9]{2}:[0-9]{2})).*$'
                    )
                WHEN 'timestamp with time zone' THEN
                    json_build_object(
                        'type', CASE WHEN col.is_nullable THEN json_build_array('string', 'null') ELSE to_json('string'::text) END,
                        'format', 'date-time',
                        'pattern', '(?:[Zz]|[+-][0-9]{2}:[0-9]{2})$'
                    )
                WHEN 'interval' THEN
                    json_build_object(
                        'type', CASE WHEN col.is_nullable THEN json_build_array('string', 'null') ELSE to_json('string'::text) END,
                        'format', 'duration'
                    )
                ELSE
                    json_build_object()
            END
        ) FROM target_table_columns AS col
    ),
    required_section(document) AS (
        SELECT
            coalesce(json_agg(col.column_name), json_build_array())
        FROM target_table_columns AS col
        WHERE NOT col.is_nullable
    )
    SELECT CASE
        WHEN
            (SELECT count(*) FROM target_table AS tbl) = 0 THEN NULL
        ELSE
            json_build_object(
                '$schema', 'https://json-schema.org/draft/2019-09/schema#',
                '$id', 'https://telitas.dev/extract_schema.psm/' || (SELECT tbl.table_schema || '/' || tbl.table_name FROM target_table AS tbl) || '/schema#',
                'type','array',
                'items', json_build_object(
                    '$ref', '#/definitions/row'
                ),
                'definitions', json_build_object(
                    'row', json_build_object(
                        'type', 'object',
                        'additionalProperties', false,
                        'properties', (SELECT rowsec.document FROM row_section AS rowsec),
                        'required', (SELECT reqsec.document FROM required_section AS reqsec)
                    )
                )
            )
        END
    INTO generated_document;
    
    RETURN generated_document;
END;
$extract_table_as_json$ LANGUAGE plpgsql;
COMMENT ON FUNCTION extract_table_as_json IS
'DESCRIPTION:
    Extract the table schema as JSON.(preview)
    
    This function is a preview.
    That is because JSON Schema is in draft.
    
PARAM: table_name CHARACTER VARYING
    Target table name to extract the schema as JSON.
    
PARAM: schema_name CHARACTER VARYING (DEFAULT: invoker current schema)
    The name of the schema to search for the table.
    
RETURN: JSON
    Generated JSON Schema document.
    If the table is not found, it will be NULL.
    
VERSION: ${version}
    
LAST UPDATE: ${last_update}
    
LICENSE:
    Copyright (c) 2022 telitas
    This function is released under the MIT License.
    See the LICENSE.txt file or https://opensource.org/licenses/mit-license.php for details.
'
;
