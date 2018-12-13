defmodule Argonaut.ApiMessage do
  @enforce_keys [:message]

  @derive Jason.Encoder
  defstruct message: nil, success: false, status: nil, data: %{}
end
