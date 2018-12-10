defmodule Argonautweb.Presence do
  use Phoenix.Presence, otp_app: :argonaut,
                        pubsub_server: Argonaut.PubSub
end
