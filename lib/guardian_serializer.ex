defmodule Argonaut.Guardian do
  use Guardian, otp_app: :argonaut

  alias Argonaut.{Repo, User}

  def subject_for_token(resource, _claims) do
    {:ok, "User:#{resource.id}"}
  end

  def resource_from_claims(claims) do
    [_, user_id_str] = claims["sub"] |> String.split(":")
    user_id = String.to_integer(user_id_str)
    {:ok, Repo.get(User, user_id)}
  end
end
