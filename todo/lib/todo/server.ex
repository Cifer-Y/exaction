defmodule Todo.Server do
	use GenServer

	def start_link(list_name) do
		IO.puts "Starting todo server for #{list_name}"
		GenServer.start_link(__MODULE__, list_name)
	end

	def init(list_name) do
		state = Todo.Database.get(list_name) || Todo.List.new
		{:ok, {list_name, state}}
	end

	def add(pid, entry) do
		GenServer.cast(pid, {:add, entry})
	end

	def entries(pid, date) do
		GenServer.call(pid, {:entries, date})
	end

	def handle_cast({:add, entry}, {list_name, todo_list}) do
		new_state = Todo.List.add_entry(todo_list, entry)
		Todo.Database.store(list_name, new_state)
		{:noreply, {list_name, new_state}}
	end

	def handle_call({:entries, date}, _caller, {list_name, todo_list}) do
		{:reply, Todo.List.entries(todo_list, date), {list_name, todo_list}}
	end
end
