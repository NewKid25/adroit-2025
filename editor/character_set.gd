class_name ELECharacterSet
extends VBoxContainer

func set_bckgs(id, b1, b2, b3):
	$OnlyDates.get_child(id).set_bckgs(b1, b2, b3)

func set_profiles(id, p1, p2, p3):
	$OnlyDates.get_child(id).set_profiles(p1, p2, p3)

func set_name_data(id, dn, n1, p1, n2, p2, n3, p3):
	$OnlyDates.get_child(id).set_name_data(dn, n1, p1, n2, p2, n3, p3)

func add_date() -> ELEDateListing:
	var n = preload("res://editor/date_listing.tscn").instantiate()
	$OnlyDates.add_child(n)
	return n

func _on_left_pressed(id) -> void:
	$"../../..".click_left.emit(get_index(), id)

func _on_middle_pressed(id) -> void:
	$"../../..".click_middle.emit(get_index(), id)

func _on_right_pressed(id) -> void:
	$"../../..".click_right.emit(get_index(), id)

func _on_edit_backgrounds_pressed(id) -> void:
	$"../../..".click_edit_backgrounds.emit(get_index(), id)


func _on_add_date_pressed() -> void:
	$"../../..".click_add_date.emit(get_index())
