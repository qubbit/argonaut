# Deploying to Azure

## Database Configuration

### Create a PostgreSQL Database

Create a database as described here: [Azure DB for PostgreSQL](https://docs.microsoft.com/en-us/azure/postgresql/quickstart-create-server-database-portal).

### Configure the database

Connect to the database using manager credentials (you would have specified these when creating the resource):

    psql -h argonaut-development.postgres.database.azure.com -U <manager>@argonaut-development postgres

Create a database and user account on database server:

    CREATE DATABASE argonaut;
    CREATE USER developer WITH PASSWORD 'banana2017!';
    GRANT ALL PRIVILEGES ON DATABASE argonaut TO developer;
    ALTER ROLE developer WITH LOGIN;

### Configure database connection

In config/dev.exs, update the database connection object:

* Add '@\<sqldb resource name\>' to the username field
* Change the hostname field to match the server name from the Overview blade
* Add `ssl: true` to the connection object

### Migrate the database

Run `mix ecto.migrate`.  You will not be able to run `mix ecto.create` with the developer credentials.