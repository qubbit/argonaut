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
