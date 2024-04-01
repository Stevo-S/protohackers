defmodule SmokeTest.Server do
  @moduledoc """
  The server module.
  Defines functions to listen on a socket,
  accept connections, and respond to messages.
  """

  @doc """
  Listens and accepts TCP connections on the given port.
  Returns an accept socket.
  """
  def listen(port) do
    {:ok, listen_socket} =
      :gen_tcp.listen(port, [:binary, packet: :raw, active: false, reuseaddr: true])

    accept_connections(listen_socket)
  end

  defp accept_connections(listen_socket) do
    {:ok, accept_socket} = :gen_tcp.accept(listen_socket)
    {:ok, controlling_pid} =
      Task.Supervisor.start_child(SmokeTest.TaskSupervisor, fn ->  serve(accept_socket) end)
    :gen_tcp.controlling_process(accept_socket, controlling_pid)

    accept_connections(listen_socket)
  end

  defp serve(accept_socket) do
    accept_socket
    |> read_message()
    |> write_message(accept_socket)
    serve(accept_socket)
  end

  defp read_message(accept_socket) do
    {:ok, received_message} = :gen_tcp.recv(accept_socket, 0)
    received_message
  end

  defp write_message(line, accept_socket) do
    :gen_tcp.send(accept_socket, line)
  end
end
