defmodule Bot do
  @moduledoc """
  The bot appilcation.
  """
  use Application

  @doc """
  When the application starts up, start up the Supervisor responsible for the
  discord bot
  """
  def start(_type, _args) do
    Bot.Supervisor.start_link(name: Bot.Supervisor)
  end
end
