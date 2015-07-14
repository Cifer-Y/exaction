defmodule TodoList do
	defstruct next_auto_id: 1, entries: HashDict.new

	def new(entries \\ []) do
		Enum.reduce(
			entries,
			%TodoList{},
			fn(entry, todo_list_acc) ->
				add_entry(todo_list_acc, entry)
			end
		)
	end

	def add_entry(
		%TodoList{next_auto_id: new_entry_id, entries: entries} = todo_list,
		entry
		) do
		entry = Map.put(entry, :id, new_entry_id)
		new_entries = HashDict.put(entries, new_entry_id, entry)
		%TodoList{todo_list | entries: new_entries, next_auto_id: new_entry_id + 1}
	end

	def entries(%TodoList{entries: entries}, date) do
		entries
		|> Stream.filter(fn({_, entry}) -> entry.date == date end)
		|> Enum.map(fn({_, entry}) -> entry end)
	end

	def update_entry(%TodoList{entries: entries} = todo_list, entry_id, update_fn) do
		case entries[entry_id] do
			nil -> todo_list
			old_entry ->
				old_entry_id = old_entry.id
				new_entry = %{id: ^old_entry_id} = update_fn.(old_entry)
				new_entries = HashDict.put(entries, new_entry.id, new_entry)
				%TodoList{todo_list | entries: new_entries}
		end
	end
	def update_entry(todo_list, entry_id, %{} = new_entry) do
		update_entry(todo_list, entry_id, fn(_) -> new_entry end)
	end

	def delete_entry(%TodoList{entries: entries} = todo_list, entry_id) do
		case entries[entry_id] do
			nil -> todo_list
			_ ->
				new_entries = HashDict.delete(entries, entry_id)
				%TodoList{todo_list | entries: new_entries}
		end
	end
end



# %TodoList{
# 	next_auto_id: 3, entries: %{1:  %{id: 1, date: {2014,02,21}, title: "fasdfasdf"},
# 														  2:  %{id: 2, date: {2014,02,03}, title: "fasdfasdf"}}
# }

todo_list = TodoList.new
|> TodoList.add_entry(%{id: 0, date: {2013, 12, 19}, title: "Dentist"})
|> TodoList.add_entry(%{date: {2013, 12, 20}, title: "Shopping"})
|> TodoList.add_entry(% {date: {2013, 12, 19}, title: "Movies"})
# |> IO.inspect
|> TodoList.delete_entry(1)
# |> IO.inspect

TodoList.entries(todo_list, {2013, 12, 19})
|> IO.inspect
