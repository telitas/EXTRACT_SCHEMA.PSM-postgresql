CREATE SCHEMA pgschema;
CREATE SCHEMA otherschema;

CREATE USER pguser WITH PASSWORD 'pgpassword';

GRANT USAGE ON SCHEMA pgschema TO pguser;
GRANT ALL PRIVILEGES ON SCHEMA pgschema TO pguser;

CREATE EXTENSION pgtap WITH SCHEMA pgschema;
