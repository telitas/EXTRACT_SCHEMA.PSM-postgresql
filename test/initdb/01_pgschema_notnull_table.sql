CREATE TABLE pgschema.notnull_table (
    character_varying_column CHARACTER VARYING(10) NOT NULL,
    character_large_object_column TEXT NOT NULL,
    binary_varying_column BYTEA NOT NULL,
    binary_large_object_column BYTEA NOT NULL,
    not_supported_type_column INTEGER ARRAY[3] NOT NULL
);
