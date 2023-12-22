Mix.install([:thousand_island])

require Logger

defmodule Echo do
  use ThousandIsland.Handler

  @impl ThousandIsland.Handler
  def handle_data(data, socket, state) do
    ThousandIsland.Socket.send(socket, data)
    {:continue, state}
  end
end

{:ok, pid} = ThousandIsland.start_link(port: 2112, handler_module: Echo)

Process.sleep(:infinity)
