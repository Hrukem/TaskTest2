defmodule TaskTest.Router do
@moduledoc """
Module for processing GET and POST requests.
The GET request is used to get a list of domains visited during 
the time interval passed in the request.
A POST request is used to send a list of visited links 
to the Redis database. The time when links are visited 
is the time when the request is received.
"""

	use Plug.Router
  require Logger

  @res1 "{\"domains\": [], \"status\": \"error, invalid request, request body is empty\"}"
 	@res2	"{\"status\": \"error, invalid request, request body is empty\"}"
   
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
      TaskTest.ParseGet.parse_request_get(conn)
    end
 	end

	post "/visited_links" do
    body_request = conn.body_params["links"]
    if body_request == nil or Enum.empty?(body_request) do
      Logger.warn("invalid POST request, empty body")
		  send_resp(conn, 400, @res2)

    else 
      TaskTest.ParsePost.parse_request_post(conn, body_request)
    end
	end

  #fot tetstign
	match _ do
		send_resp(conn, 404, "Oops1!")
	end

end
