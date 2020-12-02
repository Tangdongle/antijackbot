defmodule Antijackbot.System do
  use GenServer

  defmodule State do
    defstruct host: "verne.freenode.net",
              port: 6667,
              pass: "",
              nick: "AJBot",
              user: "AJBot",
              name: "Anti Jack Bot",
              client: nil,
              handlers: [],
              #channels: ["#classynerdbois"]
              channels: ["#nojacksallowed"]
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, %Antijackbot.System.State{}, name: __MODULE__)
  end

  @impl GenServer
  def init(state) do
    {:ok, client} = ExIRC.start_link!()
    {:ok, handler} = Antijackbot.JackHandler.start(client)

    IO.inspect state
    ExIRC.Client.add_handler client, handler
    ExIRC.Client.connect! client, state.host, state.port
    ExIRC.Client.logon      client, state.pass, state.nick, state.user, state.name

    {:ok, %{state | :client => client, :handlers => [handler]}}
  end

  def join(client, channel) do
    GenServer.call(client, {:join, channel})
  end

  def send(client, msg) do
    GenServer.cast(client, {:send, msg})
  end

  @impl GenServer
  def handle_cast({:send, msg}, state) do
    ExIRC.Client.msg state.client, :privmsg, "#nojacksallowed", msg
    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:join, channel}, _, state) do
    case ExIRC.Client.join state.client, channel do
      :ok -> {:reply, channel, state}
      {:error, reason} -> {:reply, reason, state}
    end
  end

  @impl GenServer
  def terminate(_, state) do
    ExIRC.Client.quit state.client, "Goodbye, cruel world."
    ExIRC.Client.stop! state.client
    :ok
  end
end


