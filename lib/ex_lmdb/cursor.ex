defmodule ExLMDB.Cursor do
  defstruct [:cur, :mode]

  import ExLMDB.Helpers

  def open(%ExLMDB.Transaction{tx: tx_ref, db: db_ref, mode: mode}, callback \\ nil) do
    result =
      case mode do
        :read_only -> :elmdb.ro_txn_cursor_open(tx_ref, db_ref)
        :read_write -> :elmdb.txn_cursor_open(tx_ref, db_ref)
      end

    with {:ok, cursor_ref} <- result do
      obj = %__MODULE__{cur: cursor_ref, mode: mode}

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

  def close(%__MODULE__{cur: cursor_ref, mode: :read_only}),
    do: :elmdb.ro_txn_cursor_close(cursor_ref)

  def close(%__MODULE__{mode: :read_write}), do: :ok

  def get(%__MODULE__{cur: cursor_ref, mode: :read_only}, cursor_op),
    do: :elmdb.ro_txn_cursor_get(cursor_ref, cursor_op)

  def get(%__MODULE__{cur: cursor_ref, mode: :read_write}, cursor_op),
    do: :elmdb.txn_cursor_get(cursor_ref, cursor_op)

  def put(%__MODULE__{cur: cursor_ref, mode: :read_write}, key, value),
    do: :elmdb.txn_cursor_put(cursor_ref, key, value)

  def first(self), do: get(self, :first)
  def last(self), do: get(self, :last)
  def next(self), do: get(self, :next)
  def set_range(self, gte_key), do: get(self, {:set_range, gte_key})

  def open!(tx, callback \\ nil), do: unwrap!(open(tx, callback))
  def close!(self), do: unwrap!(close(self))
  def get!(self, cursor_op), do: unwrap!(get(self, cursor_op))
  def put!(self, key, value), do: unwrap!(put(self, key, value))
  def first!(self), do: unwrap!(first(self))
  def last!(self), do: unwrap!(last(self))
  def next!(self), do: unwrap!(next(self))
  def set_range!(self, gte_key), do: unwrap!(set_range(self, gte_key))
end
