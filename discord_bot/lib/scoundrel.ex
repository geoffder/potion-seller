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

        "transition" ->
          {name, color} = process_transition_args(args)

          {:ok, role} =
            Api.create_guild_role(
              msg.guild_id,
              name: name,
              color: color
            )

          guild_roles = Api.get_guild_roles!(msg.guild_id)

          # return list of structs for roles user belongs to.
          member_roles =
            Enum.filter(
              guild_roles,
              fn role ->
                List.foldr(
                  Enum.map(msg.member.roles, &(&1 == role.id)),
                  false,
                  &or/2
                )
              end
            )

          everyone = get_first_item(guild_roles, :name, "@everyone")
          member_roles = List.delete(member_roles, everyone)

          case length(member_roles) > 0 do
            true ->
              old_role =
                get_all_items(
                  member_roles,
                  :permissions,
                  everyone.permissions
                )

              delete_roles(msg.guild_id, old_role)

            false ->
              :do_nothing
          end

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

  defp process_transition_args(args) when length(args) == 2 do
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

  defp delete_roles(_guild_id, tail) when tail == [], do: :ok

  defp delete_roles(guild_id, roles) when is_list(roles) do
    [role | rest] = roles
    Api.delete_guild_role!(guild_id, role.id)
    delete_roles(guild_id, rest)
  end

  defp delete_roles(guild_id, role) do
    Api.delete_guild_role!(guild_id, role.id)
  end

  defp get_first_item(tail, _key, _value) when tail == [], do: :not_found

  defp get_first_item(list, key, value) do
    [item | rest] = list

    case item == [] or Map.get(item, key) == value do
      true ->
        item

      false ->
        get_first_item(rest, key, value)
    end
  end

  defp get_all_items(list, key, value, out \\ [])
  defp get_all_items(tail, _key, _value, out) when tail == [], do: out

  defp get_all_items(list, key, value, out) do
    [item | rest] = list

    case Map.get(item, key) == value do
      true ->
        get_all_items(rest, key, value, [item | out])

      false ->
        get_all_items(rest, key, value, out)
    end
  end
end
