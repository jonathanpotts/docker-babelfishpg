# docker-babelfishpg
[Docker](https://www.docker.com/) image for [Babelfish for PostgreSQL](https://babelfishpg.org/).

Babelfish for PostgreSQL is a collection of [extensions](https://github.com/babelfish-for-postgresql/babelfish_extensions) for [PostgreSQL](https://www.postgresql.org/) that enable it to use the [Tabular Data Stream (TDS) protocol](https://docs.microsoft.com/openspecs/windows_protocols/ms-tds) and [Transact-SQL (T-SQL)](https://docs.microsoft.com/sql/t-sql/language-reference) allowing apps designed for [Microsoft SQL Server](https://docs.microsoft.com/sql/sql-server) to utilize PostgreSQL as their database. For more details, see ["Goodbye Microsoft SQL Server, Hello Babelfish"](https://aws.amazon.com/blogs/aws/goodbye-microsoft-sql-server-hello-babelfish/) from the AWS News Blog.

## Quick Start

**WARNING: Make sure to create a database dump to backup your data before installing a new image to prevent risk of data loss when changing images.**

To create a new container, run:

`docker run -d -p 1433:1433 jonathanpotts/babelfishpg`

### Example Data

Use the [example_data.sql](https://github.com/jonathanpotts/docker-babelfishpg/blob/main/example_data.sql) script to populate the database with example data.

You can then query the database using commands such as:

```sql
SELECT * FROM example_db.authors;
```

```sql
SELECT * FROM example_db.books;
```

### Advanced Setup

To initialize with a custom username, append `-u my_username` to the `docker run` command where `my_username` is the username desired.

To initialize with a custom password, append `-p my_password` to the `docker run` command where `my_password` is the password desired.

To initialize with a custom database name, append `-d my_database` to the `docker run` command where `my_database` is the database name desired. **This is the name of the database that Babelfish for PostgreSQL uses internally to store the data and is not accessible via TDS.**

#### Migration Mode

By default, the `single-db` migration mode is used.
To use a different migration mode, append `-m migration_mode` to the `docker run` command where `migration_mode` is the value for the migration mode desired.

For more information about migration modes, see [Single vs. multiple instances](https://babelfishpg.org/docs/installation/single-multiple/).

## Connecting

If you are hosting the container on your local machine, the server name is `localhost`. Otherwise, use the IP address or DNS-backed fully qualified domain name (FQDN) for the server you are hosting the container on.

Use SQL Server Authentication mode for login.

The default login for Babelfish is:

* **Username:** `babelfish_user`
* **Password:** `12345678`

If you specified a custom username and/or password, use those instead.

Many features in SQL Server Management Studio (SSMS) are currently unsupported.

### Connection string

Assuming Babelfish is hosted on the local machine, using the default settings, and you are trying to connect to a database named `example_db`, the connection string is:

`Data Source=localhost;Initial Catalog=example_db;Persist Security Info=true;User ID=babelfish_user;Password=12345678`

## Data Volume

Database data is stored in the `/data` volume.

## Building Docker Image

**NOTE: Because Git on Windows changes line-endings from LF to CRLF by default, make sure that `start.sh` has LF line-endings before building or an error will occur when running a container from the image.**

To build the Docker image, clone the repository and then run `docker build .`.

To use a different Babelfish version, you can:
 * Change `ARG BABELFISH_VERSION=<BABELFISH_VERSION_TAG>` in the `Dockerfile`
 * **-or-**
 * Run `docker build . --build-arg BABELFISH_VERSION=<BABELFISH_VERSION_TAG>`

Using the desired version tag from [babelfish-for-postgresql tags](https://github.com/babelfish-for-postgresql/babelfish-for-postgresql/tags).
