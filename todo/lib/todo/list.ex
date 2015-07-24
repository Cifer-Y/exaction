defmodule Todo.List do
	defstruct next_auto_id: 1, entries: HashDict.new

	def new(entries \\ []) do
		Enum.reduce(
			entries,
			%Todo.List{},
			fn(entry, todo_list_acc) ->
				add_entry(todo_list_acc, entry)
			end
		)
	end

	def add_entry(
		%Todo.List{next_auto_id: new_entry_id, entries: entries} = todo_list,
		entry
		) do
		entry = Map.put(entry, :id, new_entry_id)
		new_entries = HashDict.put(entries, new_entry_id, entry)
		%Todo.List{todo_list | entries: new_entries, next_auto_id: new_entry_id + 1}
	end

	def entries(%Todo.List{entries: entries}, date) do
		entries
		|> Stream.filter(fn({_, entry}) -> entry.date == date end)
		|> Enum.map(fn({_, entry}) -> entry end)
	end

	def update_entry(%Todo.List{entries: entries} = todo_list, entry_id, update_fn) do
		case entries[entry_id] do
			nil -> todo_list
			old_entry ->
				old_entry_id = old_entry.id
				new_entry = %{id: ^old_entry_id} = update_fn.(old_entry)
				new_entries = HashDict.put(entries, new_entry.id, new_entry)
				%Todo.List{todo_list | entries: new_entries}
		end
	end
	def update_entry(todo_list, entry_id, %{} = new_entry) do
		update_entry(todo_list, entry_id, fn(_) -> new_entry end)
	end

	def delete_entry(%Todo.List{entries: entries} = todo_list, entry_id) do
		case entries[entry_id] do
			nil -> todo_list
			_ ->
				new_entries = HashDict.delete(entries, entry_id)
				%Todo.List{todo_list | entries: new_entries}
		end
	end
end



