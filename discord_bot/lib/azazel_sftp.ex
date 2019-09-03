defmodule Bot.Azazel do
  @moduledoc """
  Creating a connection to the Azazel SFTP server and taking a look inside.
  """

  def open_sftp do
    # begin ssh session
    :ok = :ssh.start()

    # load password from un-commited key file.
    pass =
      File.read!("config/azazel.key")
      |> String.trim("\n")
      |> String.to_charlist()

    {:ok, channel_pid, connection} =
      :ssh_sftp.start_channel(
        'azazel.noip.me',
        12_577,
        user: 'musicmovies',
        password: pass,
        silently_accept_hosts: true
      )

    {channel_pid, connection}
  end

  def close_sftp(channel, connection) do
    :ok = :ssh_sftp.stop_channel(channel)
    :ok = :ssh.close(connection)
    :ok
  end

  @doc """
  Lists contents of directory at given path. Requires path to be a charlist,
  decide whether to use String.to_charlist() in here, or before.
  """
  def list_dir(channel, path) do
    :ssh_sftp.list_dir(channel, path)
  end

  @doc """
  Open sftp connection, list the root dir, and close the connection.
  """
  def check_root_dir do
    {channel, connection} = open_sftp()
    {:ok, contents} = list_dir(channel, '')
    :ok = close_sftp(channel, connection)
    contents
  end
end
