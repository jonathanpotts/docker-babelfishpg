# docker-babelfishpg
![Docker Image Version (latest semver)](https://img.shields.io/docker/v/jonathanpotts/babelfishpg) ![Docker Image Size with architecture (latest by date/latest semver)](https://img.shields.io/docker/image-size/jonathanpotts/babelfishpg) ![Docker Pulls](https://img.shields.io/docker/pulls/jonathanpotts/babelfishpg) ![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/jonathanpotts/docker-babelfishpg/docker-image.yml) ![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/jonathanpotts/docker-babelfishpg/babelfish-updates.yml?label=updates)

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

#### Encryption (SSL) Support

Starting with the `2.3.0` image pushed on Mar 4, 2023, encryption (SSL) support has been added to the image. You will need to configure PostgreSQL to use SSL; for instructions, see [Secure TCP/IP Connections with SSL](https://www.postgresql.org/docs/14/ssl-tcp.html).

As a very basic example, to enable encryption with a *self-signed* certificate that *expires in 365 days* and has a *subject of localhost*, in the container's terminal run the following commands:

```sh
cd /var/lib/babelfish/data
openssl req -new -x509 -days 365 -nodes -text -out server.crt -keyout server.key -subj "/CN=localhost"
chmod og-rwx server.key
echo "ssl = on" >> postgresql.conf
```

Then restart the container and encryption support should be enabled.

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

Database data is stored in the `/var/lib/babelfish/data` volume.

## Building Docker Image

> [!IMPORTANT]
> Breaking changes were made for `BABEL_5_2_0__PG_17_5`. To build an earlier version, the `before-BABEL_5_2_0__PG_17_5` branch should be used.

To build the Docker image, clone the repository and then run `docker build .`.

To use a different Babelfish version, you can:
 * Change `ARG BABELFISH_VERSION=<BABELFISH_VERSION_TAG>` in the `Dockerfile`
 * **-or-**
 * Run `docker build . --build-arg BABELFISH_VERSION=<BABELFISH_VERSION_TAG>`

The Babelfish version tags are listed at https://github.com/babelfish-for-postgresql/babelfish-for-postgresql/tags.



## Other Extensions

Adding other extensions is outside of the scope of this project. They may not be able to be used through Babelfish and may cause issues with the Babelfish extensions or not work as expected.

To address previous extension request issues, I have created branches for the `plpython3u` and `postgis` extensions. You can use them as examples for making modifications to add extensions you may need.

Future issues requesting that extensions be added to this project will most likely be closed.
