defmodule Argonaut.Mailer do

  # TODO find a better way to read prod vs non-prod config
  @config domain: Application.get_env(:mailgun, :domain),
          key: Application.get_env(:mailgun, :key),
          test_file_path: Application.get_env(:mailgun, :test_file_path),
          mode: Application.get_env(:mailgun, :mode)

  use Mailgun.Client, @config

  @from Application.get_env(:mailgun, :sender)

  defp app_root_url do
    if Mix.env == :prod do
      "theargonaut.herokuapp.com"
    else
      "localhost:3000"
    end
  end

  def send_password_reset_email(user) do
    data = %{username: user.username,
              password_reset_url: "https://#{app_root_url}/reset_password/#{user.password_reset_token}"}
    html = Mustachex.render_file("mails/reset_password.html", data)

    send_email to: user.email, from: @from, subject: "Reset your Argonaut password",
                html: html
  end

  def send_welcome_email(user) do
    send_email to: user.email,
               from: @from,
               subject: "Hello!",
               html: "<strong>Welcome!</strong>"
  end

  def send_greetings(user, file_path) do
    send_email to: user.email,
               from: @from,
               subject: "Happy b'day",
               html: "<strong>Cheers!</strong>",
               attachments: [%{path: file_path, filename: "greetings.png"}]
  end
end
