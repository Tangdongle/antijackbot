defmodule Antijackbot.JackHandler do
  require Logger

  def start(client) do
    start_link(client)
  end

  def start_link(client) do
    GenServer.start_link(__MODULE__, client, [])
  end

  def init(client) do
    {:ok, client}
  end

  def handle_info({:unrecognized, "MODE", _msg}, state) do
    Logger.debug "Mode Connected!"
    {:noreply, state}
  end

  def handle_info({:connected, host, port}, state) do
    Logger.debug "Connected to #{host}:#{port}"
    {:noreply, state}
  end

  def handle_info({:joined, channel}, state) do
    Logger.debug "Joined #{channel}"
    {:noreply, state}
  end

  def handle_info({:joined, channel, user}, state) do
    Logger.debug "Joined #{channel} as #{user}"
    {:noreply, state}
  end

  def handle_info({:received, msg, %ExIRC.SenderInfo{nick: nick} = sender, channel}, state) do
    case channel do
      "#classynerdbois" -> respond(state, msg, sender, channel)
      "#nojacksallowed" -> Logger.debug "Got debug message #{msg} from #{nick} at #{channel}"
    end
    {:noreply, state}
  end

  def handle_info({:received, msg, %ExIRC.SenderInfo{nick: nick} = _sender}, state) do
    Logger.debug "Got message #{msg} from #{nick}"
    {:noreply, state}
  end

  def handle_info({:login_failed, :nick_in_use}, state) do
    Logger.debug "Login failed, nickname in use"
    {:noreply, state}
  end

  def handle_info(:logged_in, state) do
    Logger.debug "Logged in to server"
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  #defp respond(client, msg, %ExIRC.SenderInfo{nick: "Tanger"} = _sender, channel) do
  #  ExIRC.Client.msg client, :privmsg, channel, "This is what a great man sounds like: \"#{msg}\""
  #end

  defp respond(client, msg, %ExIRC.SenderInfo{user: "~loggerer", host: "signiq.cust.bdr01.per02.wa.VOCUS.net.au"} = _sender, channel) do
    ExIRC.Client.msg client, :privmsg, channel, "I'm Jack and this is what I sound like: \"#{msg}\""
  end

  defp respond(_, msg, _, _) do
    Logger.debug "No Response to #{msg}"
  end

end
