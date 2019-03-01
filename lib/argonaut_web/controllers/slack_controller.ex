defmodule ArgonautWeb.SlackController do
  require Logger
  use Argonaut.Web, :controller

  import Argonaut.SlackUtils

  alias Argonaut.Reservation
  alias Argonaut.Reminder
  alias Argonaut.SlackApi
  alias Argonaut.Bot

  defp change_reservation(%Reservation{} = reservation, "renew", "yes") do
    changeset = Reservation.changeset(reservation, %{reserved_at: DateTime.utc_now()})
    Repo.update(changeset)

    {:ok,
     success_message(
       "I have renewed the environment for you. #{random_success_emoji()}"
     )}
  end

  defp change_reservation(%Reservation{} = reservation, "renew", "no") do
    Repo.delete!(reservation)
    {:ok, success_message("I have cleared the environment for you.")}
  end

  defp change_reservation(_, _, _) do
    {:ok, failure_message("Notification outdated. I have disabled this notification.")}
  end

  # For verifying the event subscription URL with slack
  def respond(conn, %{"challenge" => challenge}) do
    conn |> json(%{challenge: challenge})
  end

  # Ignore messages from bot
  def respond(conn, %{"event" => %{"bot_id" => _bot_id}}) do
    conn |> send_resp(:ok, "")
  end

  # For responding to commands from DMs or channels mentions
  def respond(
        conn,
        %{
          "event" =>
            %{"user" => user_id, "channel" => channel, "text" => text, "type" => _type}
        } = params
      ) do
    Logger.info([
      "Processing with #{__MODULE__}.respond/2\n",
      "Parameters: #{inspect(params)}\n",
      "Pipelines: #{inspect(conn.private.phoenix_pipelines)}"
    ])

    argonaut_user = if slack_user_id_in_record?(user_id) do
      user_by_slack_id(user_id)
    else
      fill_slack_user_name(user_id)
    end

    Logger.info("Found slack user in system #{argonaut_user.username}")

    bot_reply = Bot.reply(%{message: text, user: argonaut_user})

    slack_message = case bot_reply do
      %{success: true, message: message} ->
        success_message(message)

      %{success: false, message: message} ->
        error_message(message)
      %{success: true, data: data} ->
        data
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

    Logger.info(["Bot reply:\n", inspect(bot_reply)])

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
