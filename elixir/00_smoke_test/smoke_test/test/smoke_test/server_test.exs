defmodule SmokeTest.ServerTest do
  use ExUnit.Case

  setup do
    Application.stop(:smoke_test)
    :ok = Application.start(:smoke_test)
  end

  test "server echoing on port 4040" do
    socket = connect_to_socket()
    message = "Hello\n"
    response = send_message(message, socket)

    assert response == message
  end

  test "server handles binary messages" do
    socket = connect_to_socket()
    message = "\xB5}\xD6V\x0F\xD5\xEA\xEC\xA8J\x92\xB4\x93\xE1\xF6\xD1]\xD6\xC8\x06I\x00v\x9E\xB8<\x16-%\xCA.I\xD3\xFF\x02$\x02G\xD3\xED\x13@\x9Eq\xA3\x18\xBD\xC0\x1F\xFB\xF1\xE4\x1D\xBE\xB3\x8EP.\x1F\x99\x80\x0E\x0E\xEE]a\xBC\xA1}+D\xC1x)\xC8\x16\x18GS\x97\x82\xEC\xE5=\xCE\xE4\x87\xFAV\x9A\xBC\xE3B\x12\x15\xC1#\xD4O\xBCD\x13\xC7 ~\x87\xB5\x01\x14G2Lv\xA2!,\x12\xE7P\x99\xDF`p\x1A\x1El\xF9\xC7\x91,X\xBB\xA4e\x1DU;\x1D3\xD71\x04\xF2O\xB6p\xCD\xDAI\xF3\x19S\xDD\xB2\xFB\x1D\x9C\xE7\x91\x03e\f\xC2\x9A\xB2\x8C)\vm;bd\xA4\x04\xA8\x1E\x1F,\xA1\e\xDB&\x90\xCF\xE1mQr\xEE\xD5J\xAF\x99\xF1<&~\xC2\xA2\xB4\xD4\xE0R`}F\x82s+\x9C\xBB\x9AV\xE7L\xAC\xF0-\xF8\xA4\xFC\xBF\x88\x1F\xDC\xC2\xC4\xEF\x0E\xA6\x92WgT\xFE\xD1\x86\x83\x84\xB4\xF5w>R\"y\xC1\xEA\xC4\xE2|*\xF0\x18\xD3 "
    response = send_message(message, socket)

    assert response == message
  end

  test "server can handle 5 simultaneous connections on port 4040" do
    messages = Enum.map(1..5, fn number -> "Hello from client #{number}\n" end)
    tasks =
      for message <- messages,
        do: Task.async(fn -> send_message(message, connect_to_socket()) end)
    responses = for task <- tasks, do: Task.await(task)

    assert responses == messages
  end

  defp connect_to_socket do
    opts = [:binary, packet: :raw, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 4040, opts)

    socket
  end

  defp send_message(message, socket) do
    :ok = :gen_tcp.send(socket, message)
    {:ok, response} = :gen_tcp.recv(socket, 0, 100)

    response
  end
end
