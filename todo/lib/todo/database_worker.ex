defmodule Todo .DatabaseWorker do
	def start_link(db_folder) do
		IO.puts "Starting database worker"
		GenServer.start_link(__MODULE__, db_folder)
	end

	def init(db_folder) do
		File.mkdir_p(db_folder)
		{:ok, db_folder}
	end

	def store(database_pid, key, value) do
		GenServer.cast(database_pid, {:store, key, value})
	end

	def get(database_pid, key) do
		GenServer.call(database_pid, {:get, key})
	end

	def handle_call({:get, key}, _caller, db_folder) do
		data = case File.read(filename(db_folder, key)) do
			{:ok, contents} -> :erlang.binary_to_term(contents)
			_ -> nil
		end
		{:reply, data, db_folder}
	end

	def handle_cast({:store, key, value}, db_folder) do
		filename(db_folder, key)
		|> File.write!(:erlang.term_to_binary(value))
		{:noreply, db_folder}
	end

	defp filename(db_folder, key), do: "#{db_folder}/#{key}"
end
