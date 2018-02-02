defmodule Argonaut.Utils do
  def satisfies?(state, []), do: {:ok, state}
  def satisfies?(state, [check_fun | remaining_checks]) do
    case check_fun.(state) do
      {:ok, new_state} -> satisfies?(new_state, remaining_checks)
      {:error, _} = error -> error
    end
  end
end
