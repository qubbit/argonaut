defmodule Argonaut.Guardian do
  use Guardian, otp_app: :argonaut

  alias Argonaut.{Repo, User}

  def subject_for_token(resource, _claims) do
    {:ok, "User:#{resource.id}"}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(claims) do
    [_, user_id_str] = claims["sub"] |> String.split(":")
    user_id = String.to_integer(user_id_str)
    {:ok, Repo.get(User, user_id)}
  end

  def resource_from_claims(_claims) do
    {:error, "Unknown resource type"}
  end
end
