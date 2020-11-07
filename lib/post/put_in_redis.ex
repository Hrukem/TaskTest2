defmodule TaskTest.PutInRedis do
  require Logger

  def start(conn_redis) do
    children = [
      %{
        id: PutInRedis,
        start: {TaskTest.PutInRedis, :put_in_redis, [conn_redis]}
      }
    ]
    Supervisor.start_link(children, strategy: :one_for_one, name: PutInRedis)
  end

  def put_in_redis(conn_redis) do
    receive do
      {pid, list, key} ->
        key_str = "task_test728:" <> Kernel.to_string(key)
        redis_put(pid, conn_redis, list, key_str, key)
        put_in_redis(conn_redis)

      _ -> 
        Logger.error("Receive invalid data in the function 
                      PutInRedis.redis_put(conn_redis)")
        put_in_redis(conn_redis)         
    end
  end

  defp redis_put(pid, conn_redis, list, key_str, key) do
		case (Redix.command(conn_redis, ["LPUSH", key_str, list])) do    
			{:ok, _} -> 	
        TaskTest.ListKeysRedis.put_keys_in_list(key)
        
        #for testing
        IO.inspect(key)                              
        
        send(pid, {201, Jason.encode!%{"status" => "ok"}})

      {:error, _} ->
        Logger.warn("Incorrect operatiin of Redis")
        send(pid, {400, Jason.encode!%{"status" => "error, incorrect operation of Redis"}})
    end
  end
end
