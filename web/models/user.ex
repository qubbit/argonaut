defmodule Argonaut.User do
  use Argonaut.Web, :model

  alias Argonaut.{User, Repo}

  schema "users" do
    field :username, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :avatar_url, :string
    field :time_zone, :string
    field :is_admin, :boolean

    timestamps()
  end

  @required_fields ~w(username password)a
  @optional_fields ~w(first_name last_name is_admin avatar_url email time_zone)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> common_changeset
  end

  def profile_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required([:username])
    |> common_changeset
    |> generate_encrypted_password
  end

  def common_changeset(struct) do
    struct
    |> validate_format(:username, ~r{^\w+$})
    |> validate_format(:email, ~r/@/)
    |> validate_length(:username, min: 1)
    |> validate_length(:username, max: 127)
    |> validate_length(:password, min: 5)
    |> validate_length(:password, max: 127)
    |> validate_format(:avatar_url, ~r{^(https?|ftp)://[^\s/$.?#].[^\s]*$})
    |> validate_confirmation(:password, message: "Password does not match")
    |> unique_constraint(:username, message: "Username already taken")
    |> unique_constraint(:email, message: "Email already taken")
  end

  def registration_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++  @optional_fields)
    |> validate_required(@required_fields)
    |> generate_encrypted_password
    |> changeset
  end

  def find_and_confirm_password(params) do
    changeset = changeset(%User{}, params)
    user = Repo.get_by(User, username: String.downcase(params["username"]))

    if user == nil do
      {:error, changeset}
    end

    case authenticate(user, params["password"]) do
      true -> {:ok, user}
      _    -> {:error, changeset}
    end
  end

  defp authenticate(user, password) do
    case user do
      nil -> false
      _   -> Comeonin.Bcrypt.checkpw(password, user.password_hash)
    end
  end

  def current_user(conn) do
    Guardian.Plug.current_resource(conn)
  end

  def logged_in?(conn), do: !!current_user(conn)

  defp generate_encrypted_password(current_changeset) do
    case current_changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(current_changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        current_changeset
    end
  end
end
