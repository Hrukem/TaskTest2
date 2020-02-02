defmodule AllTest do
	use ExUnit.Case, async: false
	use Plug.Test


	test "GET request with empty body" do
		conny = conn(:get, "/visited_domains", %{})
		result = TaskTest.Router.call(conny, TaskTest.Router.init([]))
		assert result.status == 400

		assert result.state == :sent
		assert result.path_info == ["visited_domains"]
		assert result.resp_body == "\"domains\": [], \"status\": \"error, invalid request, request body is empty\""
	end


	test "GET request when initial value is less than final value or
	less than zero" do
		conny = conn(:get, "/visited_domains", %{"from"=>"102", "to"=>"100"})
		result = TaskTest.Router.call(conny, TaskTest.Router.init([]))

		assert result.state == :sent
		assert result.path_info == ["visited_domains"]
		assert result.resp_body == "\"domains\": [], \"status\": \"error, invalid request, initial value is less than zero or greater then end value\""
	end

	
	test "GET request when initial value or final value is not a digit" do
		conny = conn(:get, "/visited_domains", %{"from"=>"1A2", "to"=>"100"})
		result = TaskTest.Router.call(conny, TaskTest.Router.init([]))

		assert result.state == :sent
		assert result.path_info == ["visited_domains"]
		assert result.resp_body == "\"domains\": [], \"status\": \"error, invalid request, start value or end value is not a digit\""
	end



	test "connection with Redis" do
		{:ok, conn} = Redix.start_link("redis://localhost:6379")
		
		{:ok, answer} = Redix.command(conn, ["PING"])
		assert answer == "PONG"
		
		{a1, a2} = Redix.command(conn, ["LPUSH", "task_test728", ["qq", "zz"]])
		assert {a1, a2} == {:ok, 1}

		{b1, b2} = Redix.command(conn, ["LRANGE", "task_test728", 0, -1])
		assert {b1, b2} == {:ok, ["qqzz"]}

		Redix.command(conn, ["DEL", "task_test728"])
		Process.exit(conn, :normal)
	end


	test "POST request with empty body" do
		conny = conn(:post, "/visited_links", %{})
		result = TaskTest.Router.call(conny, TaskTest.Router.init([]))

		assert result.resp_body == "{\"status\": \"error, invalid request, request body is empty\"}"
	end


	test "POST request" do		
		list = ["qqq.com", "zzz.org", "yyy.ru", "qqq.com"]
		conny = conn(:post, "/visited_links", %{"links" => list})
		result = TaskTest.Router.call(conny, TaskTest.Router.init([]))
		
		assert result.status == 201
		assert result.state == :sent
		assert result.path_info == ["visited_links"]
		assert result.params["links"] == list
	end


	test "GET request" do
		conny = conn(:get, "/visited_domains", %{"from"=>"100", "to"=>"102"})
		result = TaskTest.Router.call(conny, TaskTest.Router.init([]))
    #assert result.status == 200

	  assert result.state == :sent
		assert result.path_info == ["visited_domains"]
		assert result.resp_body == "{\"domains\":[],\"status\":\"ok\"}"
	end


	test "list keys of requests" do
		assert Kernel.is_list(TaskTest.ListKeysRedis.get_list_keys())

		TaskTest.ListKeysRedis.put_keys_in_list(999)
		key = TaskTest.ListKeysRedis.get_list_keys() |> List.first()

		assert key == 999
	end


	test "test parse body request" do
		list_before = [	
										"https://ya.ru",
										"https://ya.ru?q=123",
										"funbox.ru",
										"https://stackoverflow.com/questions
														/11828270/how-to-exit-the-vim-editor"
					]
		list_after = [
										"ya.ru;",
										"funbox.ru;",
										"stackoverflow.com;"
									]

		assert TaskTest.ParseList.parse_list(list_before) == {:ok, list_after}
		assert TaskTest.ParseList.parse_list("abracodabra") ==
																					{:error, "invalid request body"}
	end


  test "work_with_redis" do
    list = ["qqq.com;", "zzz.org;", "yyy.ru;"]
    answer = TaskTest.WorkingWithRedis.redis_put(list, 1739)

    assert answer == "ok"

    res = TaskTest.WorkingWithRedis.redis_take(1645, 1767)
    
    assert res == ["qqq.com", "zzz.org", "yyy.ru"]
    
		{:ok, conn} = Redix.start_link("redis://localhost:6379")
		Redix.command(conn, ["DEL", "task_test728:1739"])
		Process.exit(conn, :normal)
	end


  test "time UTC" do
    t_utc = ~T[16:52:24.617000]
    t_msc = TimeUTC.time_utc_in_msc(t_utc)

    assert t_msc == 60744617000 
  end
  
end