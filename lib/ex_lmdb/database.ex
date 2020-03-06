defmodule ExLMDB.Database do
  defstruct [:env, :db]

  import ExLMDB.Helpers

  def open(path, opts \\ [], callback \\ nil) when is_binary(path) or is_list(path) do
    path =
      case path do
        p when is_binary(p) -> String.to_charlist(p)
        p when is_list(p) -> p
      end

    with {:ok, env_ref} <- :elmdb.env_open(path, opts),
         {:ok, db_ref} <- :elmdb.db_open(env_ref, [:create]) do
      obj = %__MODULE__{env: env_ref, db: db_ref}

      if callback do
        try do
          callback.(obj)
        after
          close(obj)
        end
      else
        {:ok, obj}
      end
    else
      other ->
        other
    end
  end

  def close(%__MODULE__{env: env}), do: :elmdb.env_close(env)

  def get(%__MODULE__{db: db_ref}, key), do: :elmdb.get(db_ref, key)

  def put(%__MODULE__{db: db_ref}, key, value), do: :elmdb.put(db_ref, key, value)

  def put_new(%__MODULE__{db: db_ref}, key, value), do: :elmdb.put_new(db_ref, key, value)

  def delete(%__MODULE__{db: db_ref}, key), do: :elmdb.delete(db_ref, key)

  def drop(%__MODULE__{db: db_ref}), do: :elmdb.drop(db_ref)

  def open!(path, opts \\ [], callback \\ nil), do: unwrap!(open(path, opts, callback))
  def close!(self), do: unwrap!(close(self))
  def get!(self, key), do: unwrap!(get(self, key))
  def put!(self, key, value), do: unwrap!(put(self, key, value))
  def put_new!(self, key, value), do: unwrap!(put_new(self, key, value))
  def delete!(self, key), do: unwrap!(delete(self, key))
  def drop!(self), do: unwrap!(drop(self))

  def record_count(%__MODULE__{} = self) do
    ExLMDB.Transaction.begin(self, [], fn tx ->
      ExLMDB.Cursor.open(tx, fn cursor ->
        do_count_records(cursor, 0)
      end)
    end)
  end

  def record_count!(self), do: unwrap!(record_count(self))

  defp do_count_records(cursor, 0) do
    case ExLMDB.Cursor.first(cursor) do
      {:ok, _, _} -> do_count_records(cursor, 1)
      :not_found -> {:ok, 0}
      other -> other
    end
  end

  defp do_count_records(cursor, acc) do
    case ExLMDB.Cursor.next(cursor) do
      {:ok, _, _} -> do_count_records(cursor, acc + 1)
      :not_found -> {:ok, acc}
      other -> other
    end
  end

  def empty?(%__MODULE__{} = self) do
    ExLMDB.Transaction.begin(self, [], fn tx ->
      ExLMDB.Cursor.open(tx, fn cursor ->
        case ExLMDB.Cursor.first(cursor) do
          {:ok, _, _} -> false
          :not_found -> true
          other -> other
        end
      end)
    end)
  end
end
