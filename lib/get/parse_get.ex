defmodule TaskTest.ParseGet do
  require Logger
  import Plug.Conn, only: [send_resp: 3]

  @res2 "error, invalid request, initial value is less than zero or greater then end value"
	@res3 "error, invalid request, start value or end value is not a digit"

  def parse_request_get(conn) do
    map = conn.params
    key_start = map["from"]
    key_end = map["to"]

    try do 
      key_start = String.to_integer(key_start)
      key_end = String.to_integer(key_end)
      do_get(key_start, key_end, conn)

    rescue _ ->
      Logger.warn("invalid GET request start value or end value is not a digit")
      send_resp(conn, 400, Jason.encode!%{"status" => @res3, "domains" => []})
    end
  end

  defp do_get(key_start, key_end, conn) when key_start < 0 or key_start > key_end do
    Logger.warn("invalid GET request initial value is less than zero or greater then end value")
    send_resp(conn, 400, Jason.encode!%{"status" => @res2, "domains" => []})
  end

  defp do_get(key_start, key_end, conn) do 
    if Enum.empty?(TaskTest.ListKeysRedis.get_list_keys()) do
      Logger.info("Response to GET request was sent")
      send_resp(conn, 200, Jason.encode!%{"status" => "ok", "domains" => []})

    else
      send(TakeFromRedis, {self(), key_start, key_end})

      receive do
        {num, answer} ->
          Logger.info("Response to GET request was sent")
          send_resp(conn, num, answer)
      after 500 -> parse_request_get(conn)
      end
    end
  end
end
