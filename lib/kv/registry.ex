defmodule KV.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  __MODULE__ means current module
  :ok : args
  opts: options
  `:name` is always required.
  """
  def start_link(opts) do
    # 1. Pass the name to GenServer's init
    server = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, :server, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(server, name) do
    # 2. Lookup is now done directly in ETS, without accessing the server

    #GenServer.call(server, {:lookup, name})
    case :ets.lookup(server, name) do
      [{^name, pid}] -> {:ok, pid}
      [] -> :error
    end
  end

  @doc """
  Ensures there is a bucket associated with the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  @doc """
  Stops the registry.
  """
  def stop(server) do
    GenServer.stop(server)
  end

  ## Server Callbacks

  def init(table_name) do
    # 3. We have replaced the names map by the ETS table
    names = :ets.new(table_name, [:named_table, read_concurrency: true])
    refs  = %{}
    {:ok, {names, refs}}
  end
  # 4. The previous handle_call callback for lookup was removed

  @doc """
  def handle_call({:lookup, name}, _from, {names, _} = state) do
    {:reply, Map.fetch(names, name), state}
  end
  """

  @doc """
  last version:
    def handle_cast({:create, name},  {names, refs}) do
    if Map.has_key?(names, name) do
      {:noreply,  {names, refs}}
    else
      {:ok, pid} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)   #KV.Bucket.start_link([])  before started a bucket directly, now passs via a dynamicSuperisor.
      ref = Process.monitor(pid)
      refs = Map.put(refs, ref, name)
      names  = Map.put(names, name, pid)
      {:noreply, {names, refs}}
    end
  end
  """




  def handle_cast({:create, name}, {names, refs}) do
    # 5. Read and write to the ETS table instead of the map
    case lookup(names, name) do
      {:ok, _pid} ->
        {:noreply, {names, refs}}
      :error ->
        {:ok, pid} = DynamicSupervisor.start_child(KV.BucketSupervisor, KV.Bucket)
        ref = Process.monitor(pid)
        refs = Map.put(refs, ref, name)
        :ets.insert(names, {name, pid})
        {:noreply, {names, refs}}
    end
  end

  @doc """
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref);
     names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end
  """

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    # 6. Delete from the ETS table instead of the map
    {name, refs} = Map.pop(refs, ref)
    :ets.delete(names, name)
    {:noreply, {names, refs}}
  end


    def handle_info(_msg, state) do
    {:noreply, state}
  end
end
