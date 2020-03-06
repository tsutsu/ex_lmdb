defmodule ExLMDB.RuntimeError do
  defexception [:message, :error_term]

  @impl true
  def exception(value) do
    msg = "LMDB produced error: #{inspect(value)}"
    %__MODULE__{message: msg, error_term: value}
  end
end
