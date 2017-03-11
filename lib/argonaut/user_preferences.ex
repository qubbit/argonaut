defmodule Argonaut.UserPreferences do

  @background_images ~w(
    None
    diagonal_striped_brick.png
    agsquare.png
    back_pattern.png
    az_subtle.png
    arches.png
    blu_stripes.png
    wood_pattern.png
    xv.png
    white_wave.png
    tileable_wood_texture.png
    swirl.png
    purty_wood.png
    old_mathematics.png
    cubes.png
    cream_pixels.png
    arab_tile.png
    45degreee_fabric.png
    blizzard.png
    cutcube.png
    diamonds.png
    geometry.png
    leather_1.png
    paven.png
    ravenna.png
   )

  def background_image_urls do
    @background_images
    |> Enum.map(fn f -> build_url(f) end)
  end

  def background_image_dropdown do
    @background_images
    |> Enum.map(fn u -> {normalize_filename(u), build_url(u)} end)
    |> Enum.into(%{})
  end


  defp build_url("None"), do: ""

  defp build_url(u) do
    "/images/subtle_patterns/#{u}"
  end

  defp normalize_filename(""), do: "None"

  defp normalize_filename(f) do
    f |> String.replace(".png", "")
      |> String.split("_")
      |> Enum.map(fn s -> String.capitalize(s) end)
      |> Enum.join(" ")
  end
end
