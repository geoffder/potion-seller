defmodule Bot.AzazelTest do
  use ExUnit.Case

  test "misc" do
    {pid, conn} = Bot.Azazel.open_sftp()
    # {:ok, handle} = :ssh_sftp.opendir(pid, 'Video1')
    # IO.puts(inspect(handle))

    path = 'Video1/Action/Movies/James Bond 007'
    IO.puts(inspect(:ssh_sftp.list_dir(pid, '')))
    # task = Task.async(fn -> :ssh_sftp.list_dir(pid, path) end)
    # IO.puts(inspect(Task.await(task, 50_000)))
  end
end
