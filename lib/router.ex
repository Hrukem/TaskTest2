defmodule TaskTest.Router do
@moduledoc """
Module for processing GET and POST requests.
The GET request is used to get a list of domains visited during 
the time interval passed in the request.
A POST request is used to send a list of visited links 
to the Redis database. The time when links are visited 
is the time when the request is received.
"""

	@res1 "\"domains\": [], \"status\": \"error, invalid request, request body is empty\""
	@res2 "\"domains\": [], \"status\": \"error, invalid request, initial value is less than zero or greater then end value\""
	@res3 "\"domains\": [], \"status\": \"error, invalid request, start value or end value is not a digit\""
	@res4	"{\"status\": \"error, invalid request, request body is empty\"}"
  
	use Plug.Router
  require Logger
#    Application.put_env(:elixir, :ansi_enabled, true)

   
	plug :match
	plug Plug.Parsers,
			 parsers: [:json],
			 pass: ["application/json"],
			 json_decoder: Jason 
	plug :dispatch


  get "/visited_domains" do
    if conn.params == %{} do
      Logger.warn("invalid GET request, empty body")
			send_resp(conn, 400, @res1)
		else
			map = conn.params
			key_start = map["from"]
			key_end = map["to"]

			try do
				key_start = String.to_integer(key_start)
				key_end = String.to_integer(key_end)

				if (key_start >= 0 && key_start <= key_end) do

					if Enum.empty?(TaskTest.ListKeysRedis.get_list_keys()) do
						send_resp(conn, 200, Jason.encode!%{
																						"status" => "ok",
																						"domains" => []
																					})
					else
					responce_to_request = 
						TaskTest.WorkingWithRedis.redis_take(
                                                  key_start,
                                                  key_end
                                                )

					{:ok, answer} = Jason.encode%{
																				"status" => "ok",
																			 "domains" => responce_to_request
																			 }

          Logger.info("Response to GET request was sent")
					send_resp(conn, 200, answer)
					end
				else
          Logger.warn("invalid GET request initial value is less than zero or greater then end value")
					send_resp(conn, 400, @res2)
				end

      rescue _ -> 
                  Logger.warn("invalid GET request start value or end value is not a digit")
                  send_resp(conn, 400, @res3)
			end
		end
	end


	post "/visited_links" do
    flag = Application.get_env(:task_test, :time_of_request)
    time_of_request = 
      if (flag) do
        System.os_time()
      else
        TimeUTC.time_utc_in_msc(Time.utc_now())
      end

		body_request = conn.body_params["links"]

		if (body_request == nil or Enum.empty?(body_request)) do
      Logger.warn("invalid POST request, empty body")
			send_resp(conn, 400, @res4)
		else 
			status =
				case (TaskTest.ParseList.parse_list(body_request)) do
				
					{:ok, body_list} ->  
						TaskTest.WorkingWithRedis.redis_put(
																			body_list, time_of_request
																			)
          {:error, msg} -> 
            Logger.warn("invalid POST request, request body is incorrect")
            msg
				end

      if (status == "ok") do
			  {:ok, answer} = Jason.encode%{"status" => status}
			  send_resp(conn, 201, answer)
      else
			  {:ok, answer} = Jason.encode%{"status" => status}
        send_resp(conn, 400, answer)
      end
		end
	end

	match _ do
		send_resp(conn, 404, "Oops!")
	end

end
