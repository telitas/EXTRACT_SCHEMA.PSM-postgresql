CREATE TABLE pgschema.all_types_table (
    numeric_column NUMERIC(15,6),
    decimal_column DECIMAL(15,6),
    smallint_column SMALLINT,
    integer_column INTEGER,
    bigint_column BIGINT,
    float_column FLOAT(53),
    real_column REAL,
    double_precision_column DOUBLE PRECISION,
    character_column CHARACTER(10),
    character_varying_column CHARACTER VARYING(10),
    character_large_object_column TEXT,
    binary_column BYTEA,
    binary_varying_column BYTEA,
    binary_large_object_column BYTEA,
    boolean_column BOOLEAN,
    date_column DATE,
    time_without_time_zone_column TIME WITHOUT TIME ZONE,
    time_with_time_zone_column TIME WITH TIME ZONE,
    timestamp_without_time_zone_column TIMESTAMP WITHOUT TIME ZONE,
    timestamp_with_time_zone_column TIMESTAMP WITH TIME ZONE,
    interval_column INTERVAL,
    not_supported_type_column INTEGER ARRAY[3]
);