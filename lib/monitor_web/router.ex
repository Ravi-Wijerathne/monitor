defmodule MonitorWeb.Router do
  use MonitorWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MonitorWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", MonitorWeb do
    pipe_through :browser

    live "/", DashboardLive
  end
end
