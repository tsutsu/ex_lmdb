defmodule ExLMDB.Helpers do
  defmacro unwrap!(resp) do
    quote do
      case unquote(resp) do
        :ok ->
          :ok

        {:ok, value} ->
          value

        {:ok, key, value} ->
          {key, value}

        error ->
          raise ExLMDB.RuntimeError, error
      end
    end
  end
end
