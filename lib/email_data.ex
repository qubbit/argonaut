defmodule Argonaut.EmailData do
  @enforce_keys [:message]

  defstruct message: nil, subject: "⚓️ An update from Argonaut"
end

