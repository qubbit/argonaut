defmodule Argonaut.ApiMessage do
  @enforce_keys [:message]

  defstruct message: nil, success: false
end