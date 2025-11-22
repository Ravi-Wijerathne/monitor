defmodule MonitorWeb.CoreComponents do
  @moduledoc """
  Core UI components for MonitorWeb.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  import Phoenix.Controller, only: [get_flash: 1]

  @doc """
  Renders flash notices.
  """
  attr :flash, :map, default: %{}, doc: "the map of flash messages"
  attr :kind, :atom, values: [:info, :error], doc: "used for styling"

  def flash(assigns) do
    ~H"""
    <div
      :if={msg = Phoenix.Flash.get(@flash, @kind)}
      class={"alert alert-#{@kind}"}
      role="alert"
    >
      <p><%= msg %></p>
    </div>
    """
  end

  @doc """
  Renders a group of flash messages.
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  def flash_group(assigns) do
    ~H"""
    <.flash flash={@flash} kind={:info} />
    <.flash flash={@flash} kind={:error} />
    """
  end

  @doc """
  Renders a simple form.
  """
  attr :for, :any, required: true, doc: "the datastructure for the form"
  attr :as, :any, default: nil, doc: "the server side parameter to collect all input under"

  attr :rest, :global,
    include: ~w(autocomplete name rel action enctype method novalidate target multipart),
    doc: "the arbitrary HTML attributes to apply to the form tag"

  slot :inner_block, required: true
  slot :actions, doc: "the slot for form actions, such as a submit button"

  def simple_form(assigns) do
    ~H"""
    <.form :let={f} for={@for} as={@as} {@rest}>
      <div>
        <%= render_slot(@inner_block, f) %>
        <div :for={action <- @actions}>
          <%= render_slot(action, f) %>
        </div>
      </div>
    </.form>
    """
  end
end
