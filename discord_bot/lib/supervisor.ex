defmodule Bot.Supervisor do
  @moduledoc """
  Supervisor responsible for starting the bot and keeping it up.
  """
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {Bot.Scoundrel, name: Bot.Scoundrel}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
