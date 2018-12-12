defmodule Argonaut.LocalFunctionTest do
  use ExUnit.Case
  import ExUnit.Assertions

  @base_url "http://localhost:4000"

  @moduletag :functional

  describe "user accounts" do
    setup %{} do
      HTTPoison.start
    end

    test "sign up", _context do
      membership_attributes = %{password: "abcd1234",
        email: "t333@gmail.com",
        username: "t33",
        api_token: "4ed056a56ff67b085f5974294823d0046d16220d26cd9c6bfadd917c296188ce"
      }

      payload = Jason.encode!(membership_attributes)
      {:ok, response } = HTTPoison.post("#{@base_url}/api/anonymous/users", payload, %{"Content-Type" => "application/json"})
      IO.inspect(response, label: "_____ response ____")
    end
  end
end
