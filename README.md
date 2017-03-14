<img src="web/static/assets/images/ArgonautLogo.png" height="64" alt="Logo"/>

Reserve testing environments effectively.

About
-----

This application lets you to add multiple testing environments(hosts where the applications can be deployed) and applications, and allows logged in users to create a reservation for testing apps in the specified testing environment for a period of time.

Web sockets are used to facilitate real-time update when a user reserves or releases an application and app.

Configuration
-------------

Each environment has its corresponding settings in `config/{environment}.exs` file. Your base application configuration lives in `config/config.exs`. Anything inside this file can be overridden by your environment specific settings.

Development
---------------

I use PostgreSQL for data persistence in both development and production environments. The database authentication can be setup in `config/dev.exs` for running the app locally in development. Argonaut uses the following development defaults:

```elixir
# config/dev.exs
config :argonaut, Argonaut.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "argonaut",
  username: "developer",
  password: "banana2017!",
  hostname: "localhost",
  pool_size: 10
```


To start the app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.


Production Deployment
---------------------

Please [check the Phoenix deployment guides](http://www.phoenixframework.org/docs/deployment) for better documentation. However, following is how the app is setup in heroku currently.

Make sure heroku toolbelt is installed on your system. This is easy if you are using homebrew on macOS. If you are using Linux, you know what to do ;)

```
brew install heroku
heroku login
```

Instead of hard-coding secret keys and database credentials, `config/prod.exs` gets the following environment variables from heroku instance.

```
DATABASE_URL
GUARDIAN_JWK
POOL_SIZE
SECRET_KEY_BASE
```

Add elixir buildpack for heroku:

```
heroku create --buildpack "https://github.com/HashNuke/heroku-buildpack-elixir.git"
```

Add buildpack to compile the static assets:

```
heroku buildpacks:add https://github.com/gjaldon/heroku-buildpack-phoenix-static.git
```

Enable PostgreSQL:

```
# this will setup the database and add DATABASE_URL environment
# variable to the application dyno
heroku addons:create heroku-postgresql:hobby-dev
```

Push code to heroku:

```
git push heroku master
```

Setup database pool size and run mix tasks:

```
heroku config:set POOL_SIZE=18
heroku config:set SECRET_KEY_BASE="`mix phoenix.gen.secret`"
heroku config:set GUARDIAN_JWK="something_secret"
heroku run "POOL_SIZE=2 mix Argonaut.task"
heroku run "POOL_SIZE=2 mix ecto.migrate"
# add environment variables for dyno metadata
heroku labs:enable runtime-dyno-metadata
```

Credits
-------
Logo: Viking Ship by Andrejs Kirma from the Noun Project

Images: Subtle Patterns

Assets used with CC attribution

