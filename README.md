Application for tracking visited links. The application provides a JSON API over HTTP. 

The app provides two resources:

resource for loading visits 

	POST /visited_links {"links": [ ] }

and a resource for getting statistics

	GET /visited_domains?from=1545221231&to=1545217638

The first resource is used to send an array of links in a POST request to the service. Addresses are cut from links
domains and stored in the database. The key for saving and subsequent search is the time of receipt of the request.

The second resource is used for getting a GET request for a list of unique domains visited during the transferred period.
The request specifies a time interval.

The Redis database is used for data storage. The key is used for saving in the database:

	"task_test728:xxx"

where "xxx" is the time of receipt of the request. 

Attention:
- the app was tested on Windows7.  The application was not tested on other OSS;
- the application is not configured to work together with other applications on the same port. 
  The application does not provide verification of the request path. 
  Therefore, if the path is different from the one specified in the application ("/visited_links" and "/visited_domains"), an error message will be sent in response.
- the app does not work with Cyrillic. For example, if the array of links in the POST request contains such a link
	"всеинструменты.рф"
  the entire request body will be declared invalid.
- the app adjusted to work with port 4000. To change the port, see the "Configuration" section.
- if you want to display the time when the request was received in the console, before starting in the  file   "working_with_redis.ex"     
  in the function   "redis_put(list, key)"   uncomment the string

	#IO.inspect key
	
  

CONFIGURATION.

Configuring the connection port. Port 4000 is now configured. 
To change the port number, in the file   "config.exs"    in a row

	config :task_test, cowboy_port: 4000

replace the number 4000 to the right one.

Configuring the app to work with time. Now the application is configured to work with the operating system time.
If you need to configure the application to work with the local time of the computer, in the file    "config.exs"    in a row

	config :task_test, time_of_request: true

replace "true" with "false".
Note: the time of receipt of the request is used as a key for saving in the database. 
Therefore, if the application runs for more than a day (when configured for local time), duplicate keys will appear in the database. 
This will result in incorrect data output for the GET request.



START. STOP.

To run the application, "Erlang" and "Elixir" must be installed on your computer.
Download the repository to your computer. At the command line, enter the "Task Test 2" folder.
Enter the  command 

	mix deps.get
	
After loading the dependencies, enter the command 

	mix test
  
Tests will start. Attention: you may receive a warning that the function System.stacktrace() is deprecated. 
This warning does not affect the operation of the app. Make sure the tests didn't fall. 
After completing the tests, to launch the app enter the command

	mix run --no-halt

To stop the application, press the Crl+c key twice.


TESTS.

To run tests, run the command line. Log in to the "task_test2" folder.  Type the command

	mix test
