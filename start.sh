#!/bin/sh
BABELFISH_HOME=/opt/babelfish
BABELFISH_DATA=/data/babelfish

cd ${BABELFISH_HOME}/bin

# Set default argument values
USERNAME=babelfish_user
PASSWORD=12345678
DATABASE=babelfish_db
MIGRATION_MODE=single-db

# Populate argument values from command
while getopts u:p:d:m: flag; do
	case "${flag}" in
		u) USERNAME=${OPTARG};;
		p) PASSWORD=${OPTARG};;
		d) DATABASE=${OPTARG};;
		m) MIGRATION_MODE=${OPTARG};;
	esac
done

# Initialize database cluster if it does not exist
if [ ! -f ${BABELFISH_DATA}/postgresql.conf ]; then
	./initdb -D ${BABELFISH_DATA}/ -E "UTF8"
	cat <<- EOF >> ${BABELFISH_DATA}/pg_hba.conf
		# Allow all connections
		host	all		all		0.0.0.0/0		md5
		host	all		all		::0/0				md5
	EOF
	cat <<- EOF >> ${BABELFISH_DATA}/postgresql.conf
		#------------------------------------------------------------------------------
		# BABELFISH RELATED OPTIONS
		# These are going to step over previous duplicated variables.
		#------------------------------------------------------------------------------
		listen_addresses = '*'
		allow_system_table_mods = on
		shared_preload_libraries = 'babelfishpg_tds'
		babelfishpg_tds.listen_addresses = '*'  
	EOF
	./pg_ctl -D ${BABELFISH_DATA}/ start
	./psql -c "CREATE USER ${USERNAME} WITH SUPERUSER CREATEDB CREATEROLE PASSWORD '${PASSWORD}' INHERIT;" \
		-c "DROP DATABASE IF EXISTS ${DATABASE};" \
		-c "CREATE DATABASE ${DATABASE} OWNER ${USERNAME};" \
		-c "\c ${DATABASE}" \
		-c "CREATE EXTENSION IF NOT EXISTS \"babelfishpg_tds\" CASCADE;" \
		-c "GRANT ALL ON SCHEMA sys to ${USERNAME};" \
		-c "ALTER USER ${USERNAME} CREATEDB;" \
		-c "ALTER SYSTEM SET babelfishpg_tsql.database_name = '${DATABASE}';" \
		-c "SELECT pg_reload_conf();" \
		-c "ALTER DATABASE ${DATABASE} SET babelfishpg_tsql.migration_mode = '${MIGRATION_MODE}';" \
		-c "SELECT pg_reload_conf();" \
		-c "CALL SYS.INITIALIZE_BABELFISH('${USERNAME}');"
	./pg_ctl -D ${BABELFISH_DATA}/ stop
fi

# Start postgres engine
./postgres -D ${BABELFISH_DATA}/ -i
