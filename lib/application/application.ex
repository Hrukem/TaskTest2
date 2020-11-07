defmodule TaskTest.Application do
  
	@moduledoc false

  use Application
	require Logger

  def start(_type, _args) do
    {:ok, conn_redis} = Redix.start_link("redis://localhost:6379")

    case Redix.command!(conn_redis, ["PING"]) do
      "PONG" -> start_programm(conn_redis)

           _ -> Logger.error("No connection to Redis")
                exit({:shutdown, "no connection to Redis"})
    end
  end

  defp start_programm(conn_redis) do
    children = [
      {
        Plug.Cowboy, 
        scheme: :http, 
        plug: TaskTest.Router, 
        options: [port: cowboy_port()]
      },
      %{
        id: ListKeysRedis,
        start: {TaskTest.ListKeysRedis, :start, []}
      },
      %{
        id: Launch,
        start: {TaskTest.Application, :launch, [conn_redis]}
      }
    ]
    
    opts = [strategy: :one_for_one, name: TaskTest.Supervisor]

		Logger.info("Starting application...")

    Supervisor.start_link(children, opts)
  end
	
	defp cowboy_port, do: Application.get_env(:task_test, :cowboy_port, 4000)

  def launch(conn_redis) do
    {:ok, spawn_link(TaskTest.PutInRedis, :start, [conn_redis])}
    {:ok, spawn_link(TaskTest.TakeFromRedis, :start, [conn_redis])}
  end
end
