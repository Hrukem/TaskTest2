defmodule TaskTest.ParseList do
@moduledoc """
Documentation for ParseList.
One function is list processing. A list of strings is submitted for
input, a part corresponding to a regular expression is cut from each
string, and these parts are combined into a list.
If there are duplicates, one copy remains.
"""

  @doc """

  """

  def parse_list(list) do
		try do
					regex = ~r/\w+\.\w+/
					result = 
									 Enum.map(list, fn x -> Regex.run(regex, x) end)
								|> List.flatten()
								|> Enum.uniq()
								|> Enum.map(fn x -> x <> ";" end)

					{:ok, result}

		rescue
			_ -> {:error, "invalid request body"}
		end
	end
end
