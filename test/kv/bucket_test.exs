defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
    #force the process to shutdown before next test
    bucket = start_supervised!(KV.Bucket)
    #no shutdown between tests
    #{:ok, bucket} = KV.Bucket.start_link([])
    %{bucket: bucket}
  end

  test "stores values by key V2", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil
    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end

  test "delete a value by key and read the response", %{bucket: bucket} do
    KV.Bucket.delete(bucket, "milk")
    assert KV.Bucket.get(bucket, "milk") == nil
  end

  test "delete a value by key and read the response with long response", %{bucket: bucket} do
    KV.Bucket.deleteLong(bucket, "milk")
    assert KV.Bucket.get(bucket, "milk") == nil
  end

  test "stores values by key" do
    # `bucket` is now the bucket from the setup block
    {:ok, bucket} = KV.Bucket.start_link([])
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end

  test "are temporary workers" do
    assert Supervisor.child_spec(KV.Bucket, []).restart == :temporary
  end

end