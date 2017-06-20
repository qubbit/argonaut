defmodule Argonaut.Mailer do

  alias Argonaut.{Repo, Mail, EmailData}

  # TODO find a better way to read prod vs non-prod config
  @config domain: Application.get_env(:mailgun, :domain),
          key: Application.get_env(:mailgun, :key),
          test_file_path: Application.get_env(:mailgun, :test_file_path),
          mode: Application.get_env(:mailgun, :mode)

  use Mailgun.Client, @config

  @from Application.get_env(:mailgun, :sender)

  def send_password_reset_email(user) do
    params = %{ username: user.username,
      password_reset_url: "#{app_root_url()}/reset_password/#{user.password_reset_token}"
    }
    message = Mustachex.render_file("mails/reset_password.mustache", params)
    template_data = %EmailData{ subject: "Reset your Argonaut Password", message: message }

    finalize_and_send_email(user.email, @from, template_data)
  end

  def send_general_email(email, %EmailData{} = template_data) do
    finalize_and_send_email(email, @from, template_data)
  end

  def finalize_and_send_email(to, from, %EmailData{ subject: subject } = template_data) do
    final_message = Mustachex.render_file("mails/email.mustache", Map.from_struct(template_data))

    mail_params = %{to: to,
      from: from,
      subject: subject,
      message: final_message,
      is_html: true
    }

    send_email to: to, from: from, subject: subject, html: final_message

    changeset = Mail.changeset(%Mail{}, mail_params)

    case Repo.insert(changeset) do
      {:ok, mail} ->
        mail
      {:error, changeset} ->
        changeset.errors
    end
  end

  # utilities

  defp normalize_username(user) do
    if user.first_name do
      user.first_name <> user.last_name
    else
      user.username
    end
  end

  defp app_root_url do
    if Mix.env == :prod do
      "https://theargonaut.herokuapp.com"
    else
      "http://localhost:3000"
    end
  end
end
