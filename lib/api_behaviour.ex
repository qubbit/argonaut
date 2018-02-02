defmodule ApiBehaviour do
  @callback api_response(Plug.Conn.t, ApiMessage) :: Plug.Conn.t
end
