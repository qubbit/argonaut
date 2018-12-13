defmodule TestUtils do
  def random_string(length) do
    :crypto.strong_rand_bytes(length) |> Base.url_encode64 |> binary_part(0, length)
  end

  def random_email do
    email_part = random_string(16)
    "random_email_#{email_part}@example.com"
  end
end
