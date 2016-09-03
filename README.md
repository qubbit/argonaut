<img src="web/static/assets/images/ArgonautLogo.png" height="64" alt="Logo"/>

Reserve testing environments effectively.

Configuration
-------------
Depending on what environment you are deploying the application in, you need to change the `config/{environment}.exs` file. Database connection can also be setup here. Anything inside `config/config.exs` can be overridden by your environment specific settings.

Running Locally
---------------
To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

Deploy to Heroku
----------------
Make sure heroku toolbelt is installed on your system. This is easy if you are using homebrew on macOS. If you are using Linux, you know what to do ;)

```
brew install heroku
heroku login
```

Instead of hard-coding credentials, you can check `config/prod.exs` to see how to setup environment variables for this app.

Add elixir buildpack for heroku:

```
heroku create --buildpack "https://github.com/HashNuke/heroku-buildpack-elixir.git"
```

Add buildpack to compile the static assets:

```
heroku buildpacks:add https://github.com/gjaldon/heroku-buildpack-phoenix-static.git
```

Enable postgresql:

```
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
heroku run "POOL_SIZE=2 mix Argonaut.task"
heroku run "POOL_SIZE=2 mix ecto.migrate"
```

Testing
-------
No tests have been added yet.

Credits
-------
Logo: Viking Ship by Andrejs Kirma from the Noun Project

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
