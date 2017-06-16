defmodule Argonaut.MailController do
  use Argonaut.Web, :controller

  alias Argonaut.{User, Mail, Mailer, EmailData}

  def index(conn, _params) do
    mails = Repo.all(Mail)
    render(conn, "index.json", mails: mails)
  end

  def create(conn, %{"mail" => %{"to" => to, "subject" => subject, "message" => message} = mail_params}) do
    send_to_all = mail_params["extra"]["send_to_all"]

    template_data = %EmailData{ subject: subject, message: message }

    if(send_to_all) do
      users = Repo.all(User)
      for user <- users do
        Mailer.send_general_email(user.email, template_data)
      end
    else
      Mailer.send_general_email(to, template_data)
    end

    conn |> json(%Argonaut.ApiError{message: "Mail sent", success: true})
  end

  def show(conn, %{"id" => id}) do
    mail = Repo.get!(Mail, id)
    render(conn, "show.json", mail: mail)
  end

  def update(conn, %{"id" => id, "mail" => mail_params}) do
    mail = Repo.get!(Mail, id)
    changeset = Mail.changeset(mail, mail_params)

    case Repo.update(changeset) do
      {:ok, mail} ->
        render(conn, "show.json", mail: mail)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Argonaut.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    mail = Repo.get!(Mail, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(mail)

    send_resp(conn, :no_content, "")
  end
end
