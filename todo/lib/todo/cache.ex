defmodule Todo.Cache do
	use GenServer

	def start_link do
		IO.puts "Starting todo cache"
		GenServer.start_link(__MODULE__, nil, name: :cache)
	end

	def server_process(todo_list_name) do
		GenServer.call(:cache, {:fetch_server, todo_list_name})
	end

	def init(_) do
		{:ok, HashDict.new}
	end

	def handle_call({:fetch_server, todo_list_name}, _caller, servers) do
		case HashDict.get(servers, todo_list_name) do
			nil ->
				{:ok, new_server_pid} = Todo.Server.start_link(todo_list_name)
				{:reply ,new_server_pid, HashDict.put(servers, todo_list_name, new_server_pid)}
			server_pid ->
				{:reply, server_pid, servers}
		end
	end
end
