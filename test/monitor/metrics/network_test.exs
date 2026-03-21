defmodule Monitor.Metrics.NetworkTest do
  use ExUnit.Case, async: true

  alias Monitor.Metrics.Network

  describe "collect/0" do
    test "returns valid network metrics structure" do
      result = Network.collect()

      assert is_map(result)
      assert Map.has_key?(result, :interfaces)
      assert Map.has_key?(result, :total_download_mb)
      assert Map.has_key?(result, :total_upload_mb)
      assert Map.has_key?(result, :download_speed_mbps)
      assert Map.has_key?(result, :upload_speed_mbps)
    end

    test "interfaces is a list" do
      result = Network.collect()

      assert is_list(result.interfaces)
    end

    test "speeds are non-negative" do
      result = Network.collect()

      assert result.download_speed_mbps >= 0
      assert result.upload_speed_mbps >= 0
    end

    test "total bytes are non-negative" do
      result = Network.collect()

      assert result.total_download_mb >= 0
      assert result.total_upload_mb >= 0
    end

    test "interface entries have required keys when not empty" do
      result = Network.collect()

      if length(result.interfaces) > 0 do
        iface = Enum.at(result.interfaces, 0)
        assert Map.has_key?(iface, :interface)
        assert Map.has_key?(iface, :rx_bytes)
        assert Map.has_key?(iface, :tx_bytes)
        assert Map.has_key?(iface, :rx_mb)
        assert Map.has_key?(iface, :tx_mb)
      end
    end

    test "interface values are non-negative" do
      result = Network.collect()

      for iface <- result.interfaces do
        assert iface.rx_bytes >= 0
        assert iface.tx_bytes >= 0
        assert iface.rx_mb >= 0
        assert iface.tx_mb >= 0
      end
    end
  end
end
