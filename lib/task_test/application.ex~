defmodule TaskTest.Application do
  
	@moduledoc false

  use Application
	require Logger

  def start(_type, _args) do
    children = [
			%{
				id: ListKeysRedis,
				start: {TaskTest.ListKeysRedis, :start, []}
			},
			{Plug.Cowboy, scheme: :http, plug: TaskTest.Router, options: [port: cowboy_port()]}
      
    ]
    
    opts = [strategy: :one_for_one, name: TaskTest.Supervisor]

		Logger.info("Starting application...")

    Supervisor.start_link(children, opts)
  end
	
	defp cowboy_port, do: Application.get_env(:task_test, :cowboy_port, 4000)
end
