defmodule TaskTest.ListKeysRedis do
@moduledoc """
The module is used for storing keys of data placed in Redis.
Starts the agent that stores the list. Two functions: to add new keys 
and to get the entire list. Works under the supervision of a Supervisor
"""

	use Agent

	@doc false

  def start() do
		Agent.start_link(fn -> [] end, name: __MODULE__)
  end

	def put_keys_in_list(key) do
		Agent.update(__MODULE__, fn list -> [key | list] end)
	end

	def get_list_keys() do
		Agent.get(__MODULE__, fn list -> list end)
	end
end
