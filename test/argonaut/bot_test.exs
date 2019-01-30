defmodule Argonaut.BotTest do
  use ExUnit.Case, async: false
  use ArgonautWeb.CleanupCase

  import Mock
  import Argonaut.Factory

  alias Argonaut.Bot
  alias Argonaut.Reservations

  setup_all do
    user = insert(:user)
    {:ok, user: user}
  end

  describe ".reply/1" do
    test "reserves pbm1:epa with different messages", context do
      [
        "I am using pbm1:epa for testing blah",
        "I'm using pbm1:epa for testing blah",
        "IM USING PBM1:EPA FOR TESTING BLAH",
        "I AM USING PBM1:EPA",
        "PBM1:EPA reserve"
      ] |> Enum.each(fn message ->
        with_mock Reservations, create_reservation: fn params, user ->
          %{success: true, message: "Reserved pbm1:epa"}
        end do
          reply = Bot.reply(%{message: message, user: context[:user]})
          assert %{message: "Reserved pbm1:epa", success: true} = reply
        end
      end)
    end

    test "releases pbm1:epa with different messages", context do
      [
        "I am done using pbm1:epa",
        "I'm DoNe using pbm1:epa",
        "IM DONE USING PBM1:EPA",
        "I AM DONE USING PBM1:EPA",
        "PBM1:EPA release"
      ] |> Enum.each(fn message ->
        with_mock Reservations, delete_reservation: fn params, user ->
          %{success: true, message: "Deleted your reservation on pbm1:epa"}
        end do
          reply = Bot.reply(%{message: message, user: context[:user]})
          assert %{message: "Deleted your reservation on pbm1:epa", success: true} = reply
        end
      end)
    end
  end
end
