use Mix.Config

#Configuring the connection port. Port 4000 is now configured.
#To change the port number in the expression below,
#replace the number 4000 to the right one.
config :task_test, cowboy_port: 4000

#Configure the application to determine when a request is received. 
#If the expression ends with the value "true",
#the application will operate with the operating system time.
#If the value "false" is set at the end of the expression, 
#the application will operate with the local time of the computer.
config :task_test, time_of_request: true
