class_name ELEDialogList
extends VBoxContainer

func get_row(idx: int) -> ELEDialogRow:
	return get_child(idx)

func add_row() -> ELEDialogRow:
	var r = preload("res://editor/dialog_row.tscn").instantiate()
	add_child(r)
	return r

func clear():
	for child in get_children():
		child.queue_free()
	add_row()
