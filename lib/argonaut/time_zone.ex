defmodule Argonaut.TimeZone do

  # only american time zones supported at the moment
  # 'murica 🇺🇸
  def zones do
    time_zones = ["Puerto Rico", "Indianapolis", "Phoenix", "Chicago", "New York", "Denver", "Los Angeles", "Anchorage"]
    time_zones
      |> Enum.sort
      |> Enum.map(fn tz -> {tz, String.replace("America/" <> tz, ~r/ /, "_") } end)
      |> Enum.into(%{})
  end

end
