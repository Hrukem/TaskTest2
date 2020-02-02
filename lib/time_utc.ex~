defmodule TimeUTC do
@moduledoc """
The input function gets the time in hh.mm.ss. msc format 
and returns the time in microseconds.
"""

  def time_utc_in_msc(t) do
    hour = t.hour
		min  = t.minute
		sec  = t.second
		{msc, _}  = t.microsecond
		(hour*3600 + min*60 + sec) * 1000000 + msc
  end
end
