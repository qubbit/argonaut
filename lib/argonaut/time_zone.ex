defmodule Argonaut.TimeZone do

  def zones do
    time_zones = ["Chicago", "New York", "Denver", "Los Angeles", "Anchorage"]
    time_zones |> Enum.map(fn tz -> "America/" <> tz end)
  end

end
