# docker-babelfishpg
[Docker](https://www.docker.com/) image for [Babelfish for PostgreSQL](https://babelfishpg.org/).

Babelfish for PostgreSQL is a collection of [extensions](https://github.com/babelfish-for-postgresql/babelfish_extensions) for [PostgreSQL](https://www.postgresql.org/) that enable it to use the [Tabular Data Stream (TDS) protocol](https://docs.microsoft.com/openspecs/windows_protocols/ms-tds) and [Transact-SQL (T-SQL)](https://docs.microsoft.com/sql/t-sql/language-reference) allowing apps designed for [Microsoft SQL Server](https://docs.microsoft.com/sql/sql-server) to utilize PostgreSQL as their database. For more details, see ["Goodbye Microsoft SQL Server, Hello Babelfish"](https://aws.amazon.com/blogs/aws/goodbye-microsoft-sql-server-hello-babelfish/) from the AWS News Blog.

## Quick Start

To create a new container, run:

`docker run -d -p 1433:1433 jonathanpotts/babelfishpg`

## Connecting

The default login for Babelfish is:

* **Username:** `babelfish_user`
* **Password:** `12345678`

Babelfish does not currently support the SSMS Object Explorer. If you are using SSMS, you must connect via a **New Query**.

## Data Volume

Database data is stored in the `/data` volume.
