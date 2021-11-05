#!/bin/sh

cd /usr/local/pgsql/bin

# Set default argument values
USERNAME=babelfish_user
PASSWORD=12345678
DATABASE=babelfish_db
MIGRATION_MODE=single-db

# Populate argument values from command
while getopts u:p:d:m: flag
do
    case "${flag}" in
        u) USERNAME=${OPTARG};;
        p) PASSWORD=${OPTARG};;
        d) DATABASE=${OPTARG};;
        m) MIGRATION_MODE=${OPTARG};;
    esac
done

# Initialize database cluster if it does not exist
[ ! -f /data/postgres/postgresql.conf ] && ./initdb -D /data/postgres \
  && printf "# Allow all connections\nhost\tall\t\tall\t\t0.0.0.0/0\t\tmd5\nhost\tall\t\tall\t\t::0/0\t\t\tmd5\n" >> /data/postgres/pg_hba.conf \
  && printf "\n# Configure babelfish\nshared_preload_libraries = 'babelfishpg_tds'\n" >> /data/postgres/postgresql.conf \
  && ./pg_ctl -D /data/postgres start \
  && ./psql -c "CREATE USER ${USERNAME} WITH CREATEDB CREATEROLE PASSWORD '${PASSWORD}' INHERIT;" \
    -c "DROP DATABASE IF EXISTS ${DATABASE};" \
    -c "CREATE DATABASE ${DATABASE} OWNER ${USERNAME};" \
    -c "\c ${DATABASE}" \
    -c "CREATE EXTENSION IF NOT EXISTS \"babelfishpg_tds\" CASCADE;" \
    -c "GRANT ALL ON SCHEMA sys to ${USERNAME};" \
    -c "ALTER SYSTEM SET babelfishpg_tsql.database_name = '${DATABASE}';" \
    -c "ALTER SYSTEM SET babelfishpg_tds.set_db_session_property = true;" \
    -c "ALTER DATABASE ${DATABASE} SET babelfishpg_tsql.migration_mode = '${MIGRATION_MODE}';" \
    -c "SELECT pg_reload_conf();" \
    -c "CALL SYS.INITIALIZE_BABELFISH('${USERNAME}');" \
  && ./pg_ctl -D /data/postgres stop

# Start postgres engine
./postgres -D /data/postgres -i
