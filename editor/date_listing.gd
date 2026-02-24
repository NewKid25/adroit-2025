class_name ELEDateListing
extends HBoxContainer

func set_bckgs(b1, b2, b3):
	$GridContainer/Bg1.texture = load(b1)
	$GridContainer/Bg2.texture = load(b2)
	$GridContainer/Bg3.texture = load(b3)

func set_profiles(p1, p2, p3):
	$GridContainer/P1.texture = load(p1)
	$GridContainer/P2.texture = load(p2)
	$GridContainer/P3.texture = load(p3)

func set_name_data(dn, n1, p1, n2, p2, n3, p3):
	$ScrollContainer/VBoxContainer/Label.text = \
'"%s" with "%s" (%s) "%s" (%s) and "%s" (%s)' % \
[dn, n1, p1, n2, p2, n3, p3]


func _on_left_pressed() -> void:
	get_parent().get_parent()._on_left_pressed(get_index())


func _on_middle_pressed() -> void:
	get_parent().get_parent()._on_middle_pressed(get_index())


func _on_right_pressed() -> void:
	get_parent().get_parent()._on_right_pressed(get_index())


func _on_edit_backgrounds_pressed() -> void:
	get_parent().get_parent()._on_edit_backgrounds_pressed(get_index())
