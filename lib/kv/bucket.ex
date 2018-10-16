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

  @doc """
  Deletes `key` from `bucket`.
  Returns the current value of `key`, if `key` exists.
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end

  @doc """
  same as update but added some timeout
  """
  def deleteLong(bucket, key) do
    Process.sleep(1000) # puts client to sleep
    Agent.get_and_update(bucket, fn dict ->
      Process.sleep(1000) # puts server to sleep
      Map.pop(dict, key)
    end)
  end
end