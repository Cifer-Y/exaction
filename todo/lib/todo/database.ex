defmodule Todo.Database do
	def start_link(db_folder) do
		IO.puts "Strating database"
		GenServer.start_link(__MODULE__, db_folder, name: :database)
	end

	def init(db_folder) do
		map_fun = fn(n) ->
			{:ok, worker} = Todo.DatabaseWorker.start_link(db_folder)
			{n, worker}
		end
		workers = [0,1,2]
		|> Enum.map(map_fun)
		|> Enum.into(HashDict.new)
		{:ok, workers}
	end

	def get_worker(key) do
		GenServer.call(:database, {:get_worker, key})
	end

	def store(key, value) do
		key
		|> get_worker
		|> Todo.DatabaseWorker.store(key, value)
	end

	def get(key) do
		key
		|> get_worker
		|> Todo.DatabaseWorker.get(key)
	end

	def handle_call({:get_worker, key}, _caller, workers) do
		worker_index = :erlang.phash2(key, 3)
		worker = HashDict.get(workers, worker_index)
		{:reply, worker, workers}
	end
end
