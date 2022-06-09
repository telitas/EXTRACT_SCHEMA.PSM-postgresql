CREATE OR REPLACE VIEW pgschema.literal_view AS
SELECT
    0::NUMERIC AS numeric_literal,
    0::SMALLINT AS smallint_literal,
    0::INTEGER AS integer_literal,
    0::BIGINT AS bigint_literal,
    0::REAL AS real_literal,
    0::DOUBLE PRECISION AS double_precision_literal,
    '0'::CHARACTER AS character_literal,
    '0'::CHARACTER VARYING AS character_varying_literal,
    '0'::TEXT AS character_large_object_literal,
    E'\\x00'::BYTEA AS binary_large_object_literal,
    false::BOOLEAN AS boolean_literal,
    DATE '0001-01-01'::DATE AS date_literal,
    TIME '000:00:00'::TIME AS time_literal,
    TIMESTAMP '0001-01-01T00:00:00'::TIMESTAMP AS timestamp_literal,
    INTERVAL '0' SECOND::INTERVAL AS interval_literal,
    NULL AS null_literal
;
