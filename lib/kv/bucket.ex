defmodule KV.Bucket do
  use Agent
  @moduledoc """
  simple bucket module to put values and retrive it from a bucket
  use of Agents to protect and handle state for us
  """

  @doc """
  Starts a new bucket.
  """
 def start_link (_opts) do
   Agent.start_link(fn  -> %{}  end)
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(bucket, key) do
    Agent.get(bucket, fn state -> Map.get(state, key)  end)
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end
end