defmodule TaskTest.WorkingWithRedis do
@moduledoc """
Module for working with the Redis database. The redis_put(list, key)
function puts the list in the database. "Key" is the time of receipt
of the request in microseconds. The redis_take(key_start, key_end)
function takes data from the database. "Key_start" and "key_end" 
start and end of the range of keys that are searched in the database.
"""

  require Logger

	def redis_put(list, key) do 
		IO.inspect key
		key_str = "task_test728:" <> Kernel.to_string(key)
		answer =
			case (Redix.start_link("redis://localhost:6379")) do
				{:ok, conn} -> put_in_redis(conn, list, key_str, key)

				{:error, _} -> 
				  case Redix.start_link("redis://localhost:6379") do
            {:ok, conn} -> put_in_redis(conn, list, key_str, key)

            {:error,_} -> 
              Logger.warn("No cooectine to Redis")
              "error, no connection to Redis"
					end
			end
    answer
	end

	defp put_in_redis(conn, list, key_str, key) do
		case (Redix.command(conn, ["LPUSH", key_str, list])) do

			{:ok, _} -> 	
        TaskTest.ListKeysRedis.put_keys_in_list(key)
        Logger.info("POST request successfully processed")
				Process.exit(conn, :normal)
				"ok"

			{:error, _} -> 
				case Redix.command(conn, ["LPUSH", key_str, list]) do
					{:ok, _} ->
            TaskTest.ListKeysRedis.put_keys_in_list(key)
            Logger.info("POST request successfully processed") 
						Process.exit(conn, :normal)
						"ok"

					{:error, _} ->
            Logger.warn("Incorrect operatiin of Redis")
						Process.exit(conn, :normal)
						"error, incorrect operation of Redis"
				end
		end
	end

	def redis_take(key_start, key_end) do

		list_keys = Enum.filter(TaskTest.ListKeysRedis.get_list_keys(), 
																fn x -> key_start <= x and x <= key_end end)

		{:ok, conn} = Redix.start_link("redis://localhost:6379")
		responce_to_request = take_from_redis(list_keys, conn, "")		
		Process.exit(conn, :normal)
		responce_to_request
	end

  defp take_from_redis([h|t], conn, accum) do
		key = "task_test728:" <> Kernel.to_string(h)
		{:ok, list} = Redix.command(conn, ["LRANGE", key, 0, -1])
		accum = accum <> List.to_string(list)
		take_from_redis(t, conn, accum)
	end

	defp take_from_redis([], _conn, accum) do
		accum
		|> String.split(";")
		|> Enum.uniq()
		|> List.delete_at(-1)		
	end
end

