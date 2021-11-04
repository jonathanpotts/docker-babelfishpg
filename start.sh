#!/bin/sh

cd /usr/local/pgsql/bin

# Initialize database cluster if it does not exist
[ ! -e /data/babelfish ] && ./initdb -D /data/postgres \
  && printf "# Allow all connections\nhost\tall\t\tall\t\t0.0.0.0/0\t\tmd5\nhost\tall\t\tall\t\t::0/0\t\t\tmd5\n" >> /data/postgres/pg_hba.conf \
  && printf "\n# Configure babelfish\nshared_preload_libraries = 'babelfishpg_tds'\n" >> /data/postgres/postgresql.conf \
  && ./pg_ctl -D /data/postgres start \
  && ./psql -c "CREATE USER babelfish_user WITH CREATEDB CREATEROLE PASSWORD '12345678' INHERIT;" \
    -c "DROP DATABASE IF EXISTS babelfish_db;" \
    -c "CREATE DATABASE babelfish_db OWNER babelfish_user;" \
    -c "\c babelfish_db" \
    -c "CREATE EXTENSION IF NOT EXISTS \"babelfishpg_tds\" CASCADE;" \
    -c "GRANT ALL ON SCHEMA sys to babelfish_user;" \
    -c "ALTER SYSTEM SET babelfishpg_tsql.database_name = 'babelfish_db';" \
    -c "ALTER SYSTEM SET babelfishpg_tds.set_db_session_property = true;" \
    -c "ALTER DATABASE babelfish_db SET babelfishpg_tsql.migration_mode = 'single-db';" \
    -c "SELECT pg_reload_conf();" \
    -c "CALL SYS.INITIALIZE_BABELFISH('babelfish_user');" \
  && ./pg_ctl -D /data/postgres stop

# Start postgres engine
./postgres -D /data/postgres -i
