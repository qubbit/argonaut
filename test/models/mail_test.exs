defmodule Argonaut.MailTest do
  use Argonaut.ModelCase

  alias Argonaut.Mail

  @valid_attrs %{from: "some content", is_html: true, message: "some content", subject: "some content", to: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Mail.changeset(%Mail{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Mail.changeset(%Mail{}, @invalid_attrs)
    refute changeset.valid?
  end
end
