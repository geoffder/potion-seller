defmodule Bot.Scoundrel do
  @moduledoc """
  A simple discord bot, not sure what I want it to do yet. Really, this is
  practice for writing in Elixir.
  """
  use Nostrum.Consumer

  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  @impl true
  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "!potion" ->
        Api.create_message(
          msg.channel_id,
          "My potions are too strong for you traveller!"
        )

      "!check_root" ->
        contents = Bot.Azazel.check_root_dir()

        Api.create_message(
          msg.channel_id,
          "Azazel root contents:\n```[#{Enum.join(contents, ", ")}]```"
        )

      _ ->
        :ignore
    end
  end

  # Catch all for events with no matching method defined to handle them.
  def handle_event(_event) do
    :noop
  end
end
