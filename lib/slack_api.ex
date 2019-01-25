# Makes fire and forget web requests to Slack
defmodule Argonaut.SlackApi do
  require Logger

  # We use this token for authenticating the slack bot
  @token Application.get_env(:argonaut, :slack_bot_oauth_token)
  @slack_headers [{"Content-Type", "application/json"}, {"Authorization", "Bearer #{@token}"}]

  # This token is sent by Argonaut to slack as part of the callback_id
  # parameter. Argonaut will verify it for message's authenticity
  @argonaut_token Application.get_env(:argonaut, :argonaut_token_for_slack)

  defp build_callback_id(reminder_id, reservation_id) do
    "#{@argonaut_token}|#{reminder_id}|#{reservation_id}"
  end

  def send_notification(text, user, reminder_id, reservation_id) do
    attachments =
      build_callback_id(reminder_id, reservation_id)
      |> build_notification_attachment

    send_message(text, attachments, user)
  end

  def disable_outdated_notification(pretext, channel, timestamp) do
    attachments =
      build_update_attachments(
        pretext,
        "Notification outdated. I have disabled this notification.",
        # disabled gray
        "bdbdbd"
      )

    update_message(attachments, channel, timestamp)
  end

  def send_action_success(text, pretext, channel, timestamp) do
    attachments =
      build_update_attachments(
        pretext,
        text,
        # successful green
        "4caf50"
      )

    update_message(attachments, channel, timestamp)
  end

  def user_info(user_id) do
    response = HTTPoison.get!("https://slack.com/api/users.info?token=#{@token}&user=#{user_id}")
    response.body |> Jason.decode!(keys: :atoms)
  end

  defp update_message(attachments, channel, timestamp) do
    payload =
      %{
        attachments: attachments,
        channel: channel,
        pretty: 1,
        ts: timestamp
      }
      |> Jason.encode!()

    url = "https://slack.com/api/chat.update"
    HTTPoison.post(url, payload, @slack_headers)
  end

  def send_message(text, attachments, channel) do
    payload =
      %{
        channel: channel,
        attachments: attachments,
        as_user: true,
        text: text
      }
      |> Jason.encode!()

    url = "https://slack.com/api/chat.postMessage"
    HTTPoison.post(url, payload, @slack_headers)
  end

  defp log_response(response, function) do
    Logger.info("#{inspect(function)} Response:\n#{inspect(response)}\n")
  end

  defp endpoint_path(chat_method) do
    "https://slack.com/api/chat.#{chat_method}?token=#{@token}&as_user=true"
  end

  defp build_notification_attachment(callback_id) do
    [
      %{
        fallback:
          "Please *renew* or *release* this environment by going to <https://argonaut.ninja>",
        callback_id: callback_id,
        color: "#3AA3E3",
        attachment_type: "default",
        actions: [
          %{
            name: "renew",
            text: "Yes",
            type: "button",
            value: "yes",
            style: "primary"
          },
          %{
            name: "renew",
            text: "No",
            type: "button",
            value: "no",
            style: "danger"
          }
        ]
      }
    ]
    |> Jason.encode!()
  end

  defp build_update_attachments(pretext, text, color) do
    [%{pretext: pretext, text: text, color: color}] |> Jason.encode!()
  end
end
