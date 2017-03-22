defimpl Poison.Encoder, for: [Ecto.DateTime] do
  # this is a hack, it will append Z to the timestamps
  # to covert them to UTC time string
  def encode(t, _options) do
    "\"" <> to_string(t) <> "Z\""
  end
end
