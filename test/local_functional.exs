defmodule Argonaut.LocalFunctionTest do
  use ExUnit.Case
  import ExUnit.Assertions
  import TestUtils

  @base_url "http://localhost:4000"

  @moduletag :functional

  describe "user accounts" do
    setup %{} do
      HTTPoison.start()
    end

    test "sign up", _context do
      email = random_email()
      username = random_string(10)

      membership_attributes = %{
        password: "abcd1234",
        email: email,
        username: username,
        api_token: random_string(32)
      }

      payload = Jason.encode!(membership_attributes)

      {:ok, response} =
        HTTPoison.post("#{@base_url}/api/anonymous/users", payload, %{
          "Content-Type" => "application/json"
        })

      assert 201 = response.status_code
    end

    test "reset password", _context do
      email = random_email()
      username = random_string(10)

      membership_attributes = %{
        password: "abcd1234",
        email: email,
        username: username,
        api_token: random_string(32)
      }

      payload = Jason.encode!(membership_attributes)

      {:ok, response} =
        HTTPoison.post("#{@base_url}/api/anonymous/users", payload, %{
          "Content-Type" => "application/json"
        })

      assert 201 = response.status_code
    end
  end
end
