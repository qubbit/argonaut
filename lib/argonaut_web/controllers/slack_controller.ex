defmodule ArgonautWeb.SlackController do
  require Logger
  use Argonaut.Web, :controller

  alias Argonaut.Reservation
  alias Argonaut.User
  alias Argonaut.Reminder
  alias Argonaut.SlackApi

  @argonaut_token_for_slack Application.get_env(:argonaut, :argonaut_token_for_slack)

  @emojis ~w(:parrot: :aw_yeah: :white_check_mark: :happygoat: :link-success:
    :dancingmonkey: :sunflower: :balloon: :badger: :robot_face: :nyancat:
    :smiley_cat: :fox_face: :tada: :beach_with_umbrella: :panda_face:
    :awesome2: :feels-good: :1up: :call-me-hand: :cfgreen: :charmander: :coo:
    :cool-doge: :cool_cat: :coolio: :cow: :doge: :dogeshake: :eevee: :espeon:
    :eyesright: :fingerguns: :goose: :duck: :high-five: :notbad: :oohyyeah:
    :owl: :penguin_dance:)

  defp verify_argonaut_token_for_slack(@argonaut_token_for_slack),
    do: {:ok, :argonaut_token_verified}

  defp verify_argonaut_token_for_slack(_), do: {:error, :argonaut_token_invalid}

  defp random_success_emoji do
    if :rand.uniform() < 0.3 do
      Enum.random(@emojis)
    end
  end

  defp success_message(text) do
    %{text: text, color: "#4caf50"}
  end

  defp failure_message(text) do
    %{text: text, color: "#bdbdbd"}
  end

  defp error_message(text) do
    %{text: text, color: "#e53935"}
  end

  defp change_reservation(%Reservation{} = reservation, "renew", "yes") do
    changeset = Reservation.changeset(reservation, %{reserved_at: DateTime.utc_now()})
    Repo.update(changeset)

    {:ok,
     success_message(
       "You said *yes*. I have renewed the environment for you. #{random_success_emoji()}"
     )}
  end

  defp change_reservation(%Reservation{} = reservation, "renew", "no") do
    Repo.delete!(reservation)
    {:ok, success_message("You said *no*. I have cleared the environment for you.")}
  end

  defp change_reservation(_, _, _) do
    {:ok, failure_message("Notification outdated. I have disabled this notification.")}
  end

  defp lookup_slack_user(user_id) do
    SlackApi.user_info(user_id)
  end

  defp user_by_slack_id(user_id), do: Repo.get_by(User, slack_user_id: user_id)

  defp slack_user_id_in_record?(user_id) do
    nil != user_by_slack_id(user_id)
  end

  defp fill_slack_user_name(user_id) do
    %{user: %{name: username}} = lookup_slack_user(user_id)

    user_record = Repo.get_by(User, username: username)

    if user_record == nil do
      {:error, :user_not_found}
    else
      user_record |> User.slack_username_changeset(%{slack_user_id: user_id}) |> Repo.update()
    end
  end

  # For verifying the event subscription URL with slack
  def respond(conn, %{"challenge" => challenge}) do
    conn |> json(%{challenge: challenge})
  end

  # For responding to commands from DMs or channels mentions
  def respond(
        conn,
        %{
          "event" =>
            %{"user" => user_id, "channel" => channel, "text" => text, "type" => _type} = event
        } = params
      ) do
    Logger.info([
      "Costom logger Processing with #{__MODULE__}.index/2\n",
      "  Parameters: #{inspect(params)}\n",
      "  Pipelines: #{inspect(conn.private.phoenix_pipelines)}"
    ])

    bot_id = Map.get(event, "bot_id")

    if !bot_id do
      argonaut_user =
        if slack_user_id_in_record?(user_id) do
          user_by_slack_id(user_id)
        else
          fill_slack_user_name(user_id)
        end

      Logger.info("Found slack user in system #{inspect(argonaut_user)}")

      bot_reply = Bot.reply(%{message: text, user: argonaut_user})

      slack_message =
        case bot_reply do
          %{success: true, message: message} ->
            success_message(message)

          %{success: false, message: message} ->
            error_message(message)

          %{success: _, message: message} ->
            failure_message(message)

          _ ->
            %{
              text: ~s"""
              ```
              #{Jason.encode!(bot_reply)}
              ```
              """
            }
        end

      SlackApi.send_message(
        nil,
        [slack_message],
        channel
      )

      Logger.info("Simulating bot interaction #{inspect(bot_reply)}")
    end

    conn |> send_resp(:ok, "")
  end

  # For responding to clicks on interactive reminder messages
  def respond(conn, %{"payload" => json_payload}) do
    payload = Jason.decode!(json_payload)

    %{
      "callback_id" => callback_id,
      "actions" => actions,
      "original_message" => %{"text" => prompt}
    } = payload

    [token, reminder_id, reservation_id] = String.split(callback_id, "|")
    %{"name" => action, "value" => value} = hd(actions)

    response =
      with {:ok, _token_verified} <- verify_argonaut_token_for_slack(token),
           {:ok, reservation} <- {:ok, Repo.get(Reservation, reservation_id)},
           {:ok, attachment} <- change_reservation(reservation, action, value) do
        from(r in Reminder, where: r.id == ^reminder_id) |> Repo.delete_all()

        %{
          text: prompt,
          attachments: [attachment]
        }
      else
        {:error, :argonaut_token_invalid} ->
          %{text: prompt, attachments: error_message("Invalid Argonaut token")}

        _ ->
          %{
            text: prompt,
            attachments:
              error_message(
                "Hmm... something went wrong while processing that response. :thinking_face:"
              )
          }
      end

    conn |> json(response)
  end
end
