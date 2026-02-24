class_name ELEDialogRow
extends HBoxContainer

signal open_clicked(rowid: int, colid: int)
signal trigger_changed(rowid: int, colid: int, trigger: int)
signal add_another_clicked(rowid: int)

var cols := 1

func mark_row_idx(rowid: int):
	$RowIndex.text = str(rowid + 1)

func mark_first_row():
	$DialogNode.mark_first_row()
	$AddAnother.visible = false

func set_trigger(colid: int, trigger: int):
	get_child(colid).set_trigger(trigger)

func set_text(colid: int, text: String):
	get_child(colid).set_text(text)

func remove_col_idx(colid: int):
	assert(colid < cols)
	get_child(colid).queue_free()
	cols -= 1

func add_column() -> int:
	var n = $DialogNode.duplicate()
	add_child(n)
	move_child(n, cols)
	cols += 1
	return cols - 1


func _on_trigger_changed(colid: int, new_trigger: int):
	trigger_changed.emit(get_index(), colid, new_trigger)

func _on_open_pressed(colid: int):
	open_clicked.emit(get_index(), colid)

func _on_add_another_pressed():
	add_another_clicked.emit(get_index())
