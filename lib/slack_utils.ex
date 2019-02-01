defmodule Argonaut.SlackUtils do

  alias Argonaut.Repo
  alias Argonaut.User
  alias Argonaut.SlackApi

  @argonaut_token_for_slack Application.get_env(:argonaut, :argonaut_token_for_slack)

  @emojis ~w(:parrot: :aw_yeah: :white_check_mark: :happygoat: :link-success:
    :dancingmonkey: :sunflower: :balloon: :badger: :robot_face: :nyancat:
    :smiley_cat: :fox_face: :tada: :beach_with_umbrella: :panda_face:
    :awesome2: :feels-good: :1up: :call-me-hand: :cfgreen: :charmander: :coo:
    :cool-doge: :cool_cat: :coolio: :cow: :doge: :dogeshake: :eevee: :espeon:
    :eyesright: :fingerguns: :goose: :duck: :high-five: :notbad: :oohyyeah:
    :owl: :penguin_dance:)

  def verify_argonaut_token_for_slack(@argonaut_token_for_slack),
    do: {:ok, :argonaut_token_verified}

  def verify_argonaut_token_for_slack(_), do: {:error, :argonaut_token_invalid}

  def random_success_emoji do
    if :rand.uniform() < 0.3 do
      Enum.random(@emojis)
    end
  end

  def success_message(text) do
    %{text: text, color: "#4caf50"}
  end

  def failure_message(text) do
    %{text: text, color: "#bdbdbd"}
  end

  def error_message(text) do
    %{text: text, color: "#e53935"}
  end

  def lookup_slack_user(user_id) do
    SlackApi.user_info(user_id)
  end

  def user_by_slack_id(user_id), do: Repo.get_by(User, slack_user_id: user_id)

  def slack_user_id_in_record?(user_id) do
    nil != user_by_slack_id(user_id)
  end

  def fill_slack_user_name(user_id) do
    %{user: %{name: username}} = lookup_slack_user(user_id)

    user_record = Repo.get_by(User, username: username)

    if user_record == nil do
      {:error, :user_not_found}
    else
      user_record
      |> User.slack_username_changeset(%{slack_user_id: user_id})
      |> Repo.update()
    end
  end
end
