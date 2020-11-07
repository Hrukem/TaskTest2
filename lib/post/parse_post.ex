defmodule TaskTest.ParsePost do
  require Logger
  import Plug.Conn, only: [send_resp: 3]

  def parse_request_post(conn, body_request) do

    #is configured in config.exs
    flag = Application.get_env(:task_test, :time_of_request)

    time_request = 
      if (flag) do
        System.os_time()
      else
        TimeUTC.time_utc_in_msc(Time.utc_now())
      end

    try do
      list = 
        body_request
        |> Enum.map(fn x -> Regex.run(~r/\w+\.\w+/u, x) end)
        |> List.flatten()
        |> Enum.uniq()
        |> Enum.map(fn x -> x <> ";" end)

      send(PutInRedis, {self(), list, time_request})

      receive do
        {num, answer} ->
          Logger.info("POST request successfully processed")
          send_resp(conn, num, answer)
      after 500 -> parse_request_post(conn, body_request)
      end

    rescue
      _ -> 
        Logger.warn("invalid POST request, request body is incorrect")
        send_resp(conn, 400, Jason.encode!%{"status" => "error, invalid request body"})
		end
  end
end
