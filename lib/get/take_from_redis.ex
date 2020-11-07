defmodule TaskTest.TakeFromRedis do
  require Logger

  def start(conn_redis) do
    children = [
      %{
        id: TakeFromRedis,
        start: {TaskTest.TakeFromRedis, :take_from_redis, [conn_redis]}
      }
    ]
    Supervisor.start_link(children, strategy: :one_for_one, name: TakeFromRedis)
  end

  def take_from_redis(conn_redis) do
    receive do
      {pid, key_start, key_end} ->
        list_keys =
          Enum.filter(
            TaskTest.ListKeysRedis.get_list_keys(),
            fn x -> key_start <= x and x <= key_end 
            end
          )
        request = redis_take(list_keys, conn_redis, "")		

        responce_to_request =
          Jason.encode!%{"status" => "ok", "domains" => request}

        
        send(pid, {200, responce_to_request})
        take_from_redis(conn_redis)
        
      _ -> 
        Logger.error("Receive invalid data in the function 
                      TakeFromRedis.take_from_redis(conn_redis)")
        take_from_redis(conn_redis)
    end
  end

  defp redis_take([h|t], conn_redis, accum) do
		key_str = "task_test728:" <> Kernel.to_string(h)
		{:ok, list} = Redix.command(conn_redis, ["LRANGE", key_str, 0, -1])
		accum = accum <> List.to_string(list)
		redis_take(t, conn_redis, accum)
	end

	defp redis_take([], _conn_redis, accum) do
		accum
		|> String.split(";")
		|> Enum.uniq()
		|> List.delete_at(-1)		
	end
end
