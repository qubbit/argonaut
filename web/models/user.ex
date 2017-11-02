defmodule Argonaut.User do
  use Argonaut.Web, :model

  alias Argonaut.{User, Team, Repo}

  # Don't show stuff like API access token, email, is_admin, background_url
  # TODO: check where not sending these fields breaks compatibility
  @derive {Poison.Encoder, only: [:id, :username, :first_name, :last_name, :avatar_url, :time_zone ]}

  schema "users" do
    field :username, :string
    field :password_hash, :string
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :avatar_url, :string
    field :time_zone, :string
    field :is_admin, :boolean
    field :background_url, :string

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    field :password_reset_token, :string
    field :password_reset_sent_at, Ecto.DateTime

    field :confirmation_token, :string
    field :confirmation_sent_at, Ecto.DateTime
    field :confirmed_at, Ecto.DateTime

    field :api_token, :string

    many_to_many :teams, Team, join_through: "membership"
    has_many :owned_teams, Team, foreign_key: :owner_id
    has_many :reservations, Reservation, foreign_key: :user_id

    timestamps()
  end

  @required_fields ~w(username password email)a
  @optional_fields ~w(first_name last_name is_admin avatar_url time_zone background_url api_token)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> common_changeset
  end

  def reset_password_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 5)
    |> validate_length(:password, max: 127)
    |> validate_confirmation(:password, message: "Password does not match confirmation")
    |> put_change(:password_reset_token, nil)
    |> put_change(:password_reset_sent_at, nil)
    |> generate_encrypted_password
  end

  def forgot_password_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:password_reset_token, :password_reset_sent_at])
    |> validate_required([:password_reset_token, :password_reset_sent_at])
  end

  def profile_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required([:username, :email])
    |> validate_inclusion(:background_url, Argonaut.UserPreferences.background_image_urls)
    |> validate_inclusion(:time_zone, Argonaut.TimeZone.zones)
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
    |> put_change(:avatar_url, default_gravatar())
    |> generate_encrypted_password
    |> changeset
  end

  # TODO: clean up potential code smell
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


  def default_gravatar do
    s = to_string :rand.uniform * 1000000000039
    md5_hash = :crypto.hash(:md5, s) |> Base.encode16(case: :lower)
    "https://www.gravatar.com/avatar/#{md5_hash}?d=identicon"
  end

  defp generate_encrypted_password(current_changeset) do
    case current_changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(current_changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(password))
      _ ->
        current_changeset
    end
  end
end
