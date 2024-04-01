defmodule SmokeTest do
  use Application

  @moduledoc """
  Documentation for `SmokeTest`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> SmokeTest.hello()
      :world

  """
  def hello do
    :world
  end

  @doc """
  Perform tasks necessary for the application to run on startup.
  For now, this is pretty much just listening for TCP connections on port 4040
  """
  @impl Application
  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: SmokeTest.TaskSupervisor},
      {Task, fn -> SmokeTest.Server.listen(4040) end}
    ]
    opts = [strategy: :one_for_one, name: SmokeTest.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
