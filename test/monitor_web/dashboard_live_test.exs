defmodule MonitorWeb.DashboardLiveTest do
  use MonitorWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias Monitor.SystemMonitor

  setup do
    case Process.whereis(Monitor.SystemMonitor) do
      nil -> start_supervised!(Monitor.SystemMonitor)
      _pid -> :ok
    end
    :ok
  end

  describe "mount/3" do
    test "renders dashboard", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "System Monitor Dashboard"
    end

    test "displays system information", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "Hostname"
      assert html =~ "OS"
      assert html =~ "Uptime"
    end

    test "displays CPU card", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "CPU Usage"
      assert html =~ "Overall"
      assert html =~ "Cores"
    end

    test "displays Memory card", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "Memory Usage"
      assert html =~ "RAM"
    end

    test "displays Network card", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "Network Traffic"
      assert html =~ "Download"
      assert html =~ "Upload"
    end

    test "displays processes table", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "Running Processes"
      assert html =~ "PID"
      assert html =~ "Command"
    end

    test "displays footer", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/")

      assert html =~ "Last updated"
      assert html =~ "Phoenix LiveView"
    end
  end

  describe "real-time updates" do
    test "receives metrics update via PubSub", %{conn: conn} do
      metrics = SystemMonitor.get_current_metrics()
      {:ok, view, _html} = live(conn, "/")

      Phoenix.PubSub.broadcast(Monitor.PubSub, "system_metrics", {:metrics_update, metrics})

      assert render(view) =~ "System Monitor Dashboard"
    end
  end
end
