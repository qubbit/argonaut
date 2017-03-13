defmodule Argonaut.TimeZone do

  # only american time zones supported at the moment
  # 'murica 🇺🇸
  @supported_zones ["Puerto Rico",
                    "Indianapolis",
                    "Phoenix",
                    "Chicago",
                    "New York",
                    "Denver",
                    "Los Angeles",
                    "Anchorage"]
  def zones do
    @supported_zones
      |> Enum.map(fn tz -> String.replace("America/" <> tz, ~r/ /, "_") end)
  end

  def zones_dropdown do
    @supported_zones |> Enum.zip(zones()) |> Enum.into(%{})
  end

end
