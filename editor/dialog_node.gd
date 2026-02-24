class_name ELEDialogNode
extends VBoxContainer

func set_text(txt):
	$DialogRect/DialogText.text = txt

func set_range(min1, max1, min2, max2, min3, max3):
	$HBoxContainer/Numbers.text =            \
		"(%f; %f) (%f; %f) (%f; %f)" %       \
		[min1, max1, min2, max2, min3, max3]

func mark_first_row():
	$HBoxContainer/Trigger.visible = false
	$HBoxContainer/Numbers.visible = false

func set_trigger(trigger: int):
	$HBoxContainer/Trigger.select(trigger)

func _on_trigger_changed(index: int):
	get_parent()._on_trigger_changed(get_index(), index)

func _on_open_pressed():
	get_parent()._on_open_pressed(get_index())
