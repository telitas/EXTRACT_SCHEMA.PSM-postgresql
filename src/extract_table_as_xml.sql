CREATE OR REPLACE FUNCTION extract_table_as_xml(table_name CHARACTER VARYING, schema_name CHARACTER VARYING DEFAULT current_schema()) RETURNS XML AS $extract_table_as_xml$
DECLARE
/**
DESCRIPTION:
    Extract the table schema as XML.
    
PARAM: table_name CHARACTER VARYING
    Target table name to extract the schema as XML.
    
PARAM: schema_name CHARACTER VARYING (DEFAULT: invoker current schema)
    The name of the schema to search for the table.
    
RETURN: XML
    Generated XML Schema document.
    If the table is not found, it will be NULL.
    
VERSION: ${version}
    
LAST UPDATE: ${last_update}
    
LICENSE:
    Copyright (c) 2022 telitas
    This function is released under the MIT License.
    See the LICENSE.txt file or https://opensource.org/licenses/mit-license.php for details.
*/
    generated_document XML;
BEGIN
    RAISE DEBUG 'table_name=%, schema_name=%', table_name, schema_name;
    
    WITH target_table(table_schema, table_name) AS (
        SELECT
            tbl.table_schema,
            tbl.table_name
        FROM information_schema.tables AS tbl
        WHERE
			    tbl.table_schema = extract_table_as_xml.schema_name
			AND tbl.table_name = extract_table_as_xml.table_name
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
    column_type_to_document(ordinal_position, column_name, is_nullable, document) AS (
        SELECT
            col.ordinal_position,
            col.column_name,
            col.is_nullable,
            CASE col.data_type
                WHEN 'numeric' THEN
                    CASE
                        WHEN col.numeric_scale IS NULL THEN
                            xmlelement(name "xs:simpleType",
                                xmlelement(name "xs:restriction", xmlattributes('xs:decimal' AS "base"))
                            )
                        ELSE
                            xmlelement(name "xs:simpleType",
                                xmlelement(name "xs:restriction", xmlattributes('xs:decimal' AS "base"),
                                    xmlelement(name "xs:totalDigits", xmlattributes(numeric_precision AS "value")),
                                    xmlelement(name "xs:fractionDigits", xmlattributes(col.numeric_scale AS "value"))
                                )
                            )
                    END
                WHEN 'smallint' THEN
                    xmlelement(name "xs:simpleType",
                        xmlelement(name "xs:restriction", xmlattributes('xs:short' AS "base"))
                    )
                WHEN 'integer' THEN
                    xmlelement(name "xs:simpleType",
                        xmlelement(name "xs:restriction", xmlattributes('xs:int' AS "base"))
                    )
                WHEN 'bigint' THEN
                    xmlelement(name "xs:simpleType",
                        xmlelement(name "xs:restriction", xmlattributes('xs:long' AS "base"))
                    )
                WHEN 'real' THEN
                    xmlelement(name "xs:simpleType",
                        xmlelement(name "xs:restriction", xmlattributes('xs:float' AS "base"))
                    )
                WHEN 'double precision' THEN
                    xmlelement(name "xs:simpleType",
                        xmlelement(name "xs:restriction", xmlattributes('xs:double' AS "base"))
                    )
                WHEN 'character' THEN
                    CASE
                        WHEN col.character_maximum_length > 0 THEN
                            xmlelement(name "xs:simpleType",
                                xmlelement(name "xs:restriction", xmlattributes('xs:string' AS "base"),
                                    xmlelement(name "xs:length", xmlattributes(col.character_maximum_length AS "value"))
                                )
                            )
                        ELSE
                            xmlelement(name "xs:simpleType",
                                xmlelement(name "xs:restriction", xmlattributes('xs:string' AS "base"))
                            )
                    END
                WHEN 'character varying' THEN
                    CASE
                        WHEN col.character_maximum_length > 0 THEN
                            xmlelement(name "xs:simpleType",
                                xmlelement(name "xs:restriction", xmlattributes('xs:string' AS "base"),
                                    xmlelement(name "xs:maxLength", xmlattributes(col.character_maximum_length AS "value"))
                                )
                            )
                        ELSE
                            xmlelement(name "xs:simpleType",
                                xmlelement(name "xs:restriction", xmlattributes('xs:string' AS "base"))
                            )
                    END
                WHEN 'text' THEN
                    xmlelement(name "xs:simpleType",
                        xmlelement(name "xs:restriction", xmlattributes('xs:string' AS "base"))
                    )
                WHEN 'bytea' THEN
                    xmlelement(name "xs:simpleType",
                        xmlelement(name "xs:restriction", xmlattributes('xs:hexBinary' AS "base"))
                    )
                WHEN 'boolean' THEN
                    xmlelement(name "xs:simpleType",
                        xmlelement(name "xs:restriction", xmlattributes('xs:boolean' AS "base"))
                    )
                WHEN 'date' THEN
                    xmlelement(name "xs:simpleType",
                        xmlelement(name "xs:restriction", xmlattributes('xs:date' AS "base"))
                    )
                WHEN 'time without time zone' THEN
                    xmlelement(name "xs:simpleType",
                        xmlelement(name "xs:restriction", xmlattributes('xs:time' AS "base"),
                            xmlelement(name "xs:pattern", xmlattributes('.*[^+-].{4}[^Zz]' AS "value"))
                        )
                    )
                WHEN 'time with time zone' THEN
                    xmlelement(name "xs:simpleType",
                        xmlelement(name "xs:restriction", xmlattributes('xs:time' AS "base"),
                            xmlelement(name "xs:pattern", xmlattributes('.*([Zz]|[+-][0-9]{2}:[0-9]{2})' AS "value"))
                        )
                    )
                WHEN 'timestamp without time zone' THEN
                    xmlelement(name "xs:simpleType",
                        xmlelement(name "xs:restriction", xmlattributes('xs:dateTime' AS "base"),
                            xmlelement(name "xs:pattern", xmlattributes('.*[^+-].{4}[^Zz]' AS "value"))
                        )
                    )
                WHEN 'timestamp with time zone' THEN
                    xmlelement(name "xs:simpleType",
                        xmlelement(name "xs:restriction", xmlattributes('xs:dateTime' AS "base"),
                            xmlelement(name "xs:pattern", xmlattributes('.*([Zz]|[+-][0-9]{2}:[0-9]{2})' AS "value"))
                        )
                    )
                WHEN 'interval' THEN
                    xmlelement(name "xs:simpleType",
                        xmlelement(name "xs:restriction", xmlattributes('xs:duration' AS "base"))
                    )
                ELSE NULL
            END
        FROM target_table_columns AS col
    ),
    row_section(document) AS (
        SELECT
            xmlelement(name "xs:complexType", xmlattributes('Row' AS "name"),
                xmlelement(name "xs:sequence",
                    xmlagg(
                        CASE
                            WHEN doc.is_nullable THEN xmlelement(name "xs:element", xmlattributes(doc.column_name AS "name", TRUE AS "nillable", 0 AS "minOccurs"), doc.document)
                            ELSE xmlelement(name "xs:element", xmlattributes(doc.column_name AS "name"), doc.document)
                        END
                    )
                )
            )
        FROM column_type_to_document AS doc
    ),
    root_and_key_section(document) AS (
        SELECT
            xmlelement(name "xs:element", xmlattributes('rows' AS "name", 'Rows' AS "type"),
                xmlagg(
                    CASE con.constraint_type
                        WHEN 'PRIMARY KEY' THEN xmlelement(name "xs:key", xmlattributes(con.constraint_name AS "name")
                            ,xmlelement(name "xs:selector", xmlattributes('row' AS "xpath"))
                            ,xmlelement(name "xs:field", xmlattributes(con.column_name AS "xpath")))
                        WHEN 'UNIQUE' THEN xmlelement(name "xs:unique", xmlattributes(con.constraint_name AS "name")
                            ,xmlelement(name "xs:selector", xmlattributes('row' AS "xpath"))
                            ,xmlelement(name "xs:field", xmlattributes(con.column_name AS "xpath")))
                        ELSE NULL
                    END
                )
            )
        FROM target_table_constraints AS con
        WHERE con.columns_count = 1
    )
    SELECT CASE
        WHEN (SELECT count(*) FROM target_table AS tbl) = 0
            THEN NULL
        ELSE
            xmlelement(name "xs:schema", xmlattributes('http://www.w3.org/2001/XMLSchema' AS "xmlns:xs"),
                (SELECT rootsec.document FROM root_and_key_section AS rootsec),
                xmlelement(name "xs:complexType", xmlattributes('Rows' AS "name"),
                    xmlelement(name "xs:sequence",
                        xmlelement(name "xs:element", xmlattributes('row' AS "name", 'Row' AS "type", 0 AS "minOccurs", 'unbounded' AS "maxOccurs"))
                    )
                ),
                (SELECT xmlagg(rowsec.document) FROM row_section AS rowsec)
            )
        END
    INTO generated_document;
    
    RETURN generated_document;
END;
$extract_table_as_xml$ LANGUAGE plpgsql;
COMMENT ON FUNCTION extract_table_as_xml IS
'DESCRIPTION:
    Extract the table schema as XML.
    
PARAM: table_name CHARACTER VARYING
    Target table name to extract the schema as XML.
    
PARAM: schema_name CHARACTER VARYING (DEFAULT: invoker current schema)
    The name of the schema to search for the table.
    
RETURN: XML
    Generated XML Schema document.
    If the table is not found, it will be NULL.
    
VERSION: ${version}
    
LAST UPDATE: ${last_update}
    
LICENSE:
    Copyright (c) 2022 telitas
    This function is released under the MIT License.
    See the LICENSE.txt file or https://opensource.org/licenses/mit-license.php for details.
'
;
