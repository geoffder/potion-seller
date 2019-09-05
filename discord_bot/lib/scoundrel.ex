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
    with "!" <- String.first(msg.content),
         content <- String.replace_prefix(msg.content, "!", ""),
         [command | args] <- String.split(content, "|") do
      case String.trim(command) do
        "potion" ->
          # IO.puts(inspect(msg))

          Api.create_message(
            msg.channel_id,
            "My potions are too strong for you traveller!"
          )

        "check_root" ->
          dir_contents = Bot.Azazel.check_root_dir()

          Api.create_message(
            msg.channel_id,
            "Azazel root contents:\n```[#{Enum.join(dir_contents, ", ")}]```"
          )

        "role" ->
          {name, color} = process_role_args(args)

          {:ok, role} =
            Api.create_guild_role(
              msg.guild_id,
              name: name,
              color: color
            )

          # TODO:
          # check if the user already has a non-everyone role with permissions
          # equivalent to @everyone. If they do, remove it before adding the
          # new one.
          # IO.puts(inspect(Api.get_guild_roles(msg.guild_id)))

          {:ok} =
            Api.modify_guild_member(
              msg.guild_id,
              msg.author.id,
              roles: [role.id | msg.member.roles]
            )

          Api.create_message(
            msg.channel_id,
            "You are clearly not of the strongest, you are of the #{role}!"
          )

        _ ->
          :ignore
      end
    end
  end

  # Catch all for events with no matching method defined to handle them.
  @impl true
  def handle_event(_event) do
    :noop
  end

  defp process_role_args(args) when length(args) == 2 do
    name =
      args
      |> List.first()
      |> String.trim()

    [r, g, b] =
      List.last(args)
      |> String.replace(" ", "")
      |> String.split(",")
      |> Enum.map(&(String.trim(&1) |> String.to_integer()))

    # calculate integer representation
    color = r * 256 * 256 + g * 256 + b

    {name, color}
  end

  defp prune_roles(guild_id) do
    # This function will be used to clear out ununsed roles from the server.
    IO.puts(inspect(Api.list_guild_members(guild_id, limit: 1000)))
  end
end
