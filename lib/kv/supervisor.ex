defmodule KV.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  #the Supervisor will call KV.Registry.start_link([name: KV.Registry])
  def init(:ok) do
    children = [
    {DynamicSupervisor, name: KV.BucketSupervisor, strategy: :one_for_one},
      {KV.Registry, name: KV.Registry}

    ]
    Supervisor.init(children, strategy: :one_for_all)
  end
end