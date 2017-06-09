defmodule Argonaut.Repo do
  use Ecto.Repo, otp_app: :argonaut
  use Scrivener, page_size: 25
end
