defimpl Poison.Encoder, for: [Argonaut.Application, Argonaut.Environment, Argonaut.User, Argonaut.Reservation] do
  def encode(%{__struct__: _} = struct, options) do
    struct
      |> Map.from_struct
      |> sanitize_map
      |> Poison.Encoder.Map.encode(options)
  end

  defp sanitize_map(map) do
    Map.drop(map, [:password, :password_hash, :__meta__, :__struct__])
  end
end


defimpl Poison.Encoder, for: [Ecto.DateTime] do
  # this is a hack, it will append Z to the timestamps
  # to covert them to UTC time string
  def encode(t, _options) do
    "\"" <> to_string(t) <> "Z\""
  end
end
