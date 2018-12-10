defmodule ArgonautWeb.MailView do
  use Argonaut.Web, :view

  def render("index.json", %{mails: mails}) do
    %{data: render_many(mails, Argonaut.MailView, "mail.json")}
  end

  def render("show.json", %{mail: mail}) do
    %{data: render_one(mail, Argonaut.MailView, "mail.json")}
  end

  def render("mail.json", %{mail: mail}) do
    %{id: mail.id,
      to: mail.to,
      from: mail.from,
      subject: mail.subject,
      message: mail.message,
      is_html: mail.is_html}
  end
end
