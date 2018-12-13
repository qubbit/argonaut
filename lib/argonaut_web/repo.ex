defmodule Argonaut.Repo do
  use Ecto.Repo, otp_app: :argonaut, adapter: Ecto.Adapters.Postgres
  use Scrivener, page_size: 25
end
