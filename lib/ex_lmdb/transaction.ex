defmodule ExLMDB.Transaction do
  defstruct [:db, :tx, :mode]

  import ExLMDB.Helpers

  def begin(%ExLMDB.Database{env: env_ref, db: db_ref}, opts \\ [], callback \\ nil) do
    {mode, result} =
      if Keyword.get(opts, :writable, false) do
        {:read_write, :elmdb.txn_begin(env_ref)}
      else
        {:read_only, :elmdb.ro_txn_begin(env_ref)}
      end

    with {:ok, tx_ref} <- result do
      obj = %__MODULE__{db: db_ref, tx: tx_ref, mode: mode}

      if callback do
        try do
          result = callback.(obj)
          :ok = commit(obj)
          result
        rescue
          err ->
            rollback(obj)
            reraise err, __STACKTRACE__
        end
      else
        {:ok, obj}
      end
    else
      other ->
        other
    end
  end

  def commit(%__MODULE__{tx: tx_ref, mode: :read_only}), do: :elmdb.ro_txn_commit(tx_ref)
  def commit(%__MODULE__{tx: tx_ref, mode: :read_write}), do: :elmdb.txn_commit(tx_ref)

  def rollback(%__MODULE__{tx: tx_ref, mode: :read_only}), do: :elmdb.ro_txn_abort(tx_ref)
  def rollback(%__MODULE__{tx: tx_ref, mode: :read_write}), do: :elmdb.txn_abort(tx_ref)

  def get(%__MODULE__{tx: tx_ref, db: db_ref, mode: :read_only}, key),
    do: :elmdb.ro_txn_get(tx_ref, db_ref, key)

  def get(%__MODULE__{tx: tx_ref, db: db_ref, mode: :read_write}, key),
    do: :elmdb.txn_get(tx_ref, db_ref, key)

  def put(%__MODULE__{tx: tx_ref, db: db_ref, mode: :read_write}, key, value),
    do: :elmdb.txn_put(tx_ref, db_ref, key, value)

  def put_new(%__MODULE__{tx: tx_ref, db: db_ref, mode: :read_write}, key, value),
    do: :elmdb.txn_put(tx_ref, db_ref, key, value)

  def delete(%__MODULE__{tx: tx_ref, db: db_ref, mode: :read_write}, key),
    do: :elmdb.txn_delete(tx_ref, db_ref, key)

  def drop(%__MODULE__{tx: tx_ref, db: db_ref, mode: :read_write}),
    do: :elmdb.txn_drop(tx_ref, db_ref)

  def begin!(db, opts \\ [], callback \\ nil), do: unwrap!(begin(db, opts, callback))
  def commit!(self), do: unwrap!(commit(self))
  def rollback!(self), do: unwrap!(rollback(self))
  def get!(self, key), do: unwrap!(get(self, key))
  def put!(self, key, value), do: unwrap!(put(self, key, value))
  def put_new!(self, key, value), do: unwrap!(put_new(self, key, value))
  def delete!(self, key), do: unwrap!(delete(self, key))
  def drop!(self), do: unwrap!(drop(self))
end
