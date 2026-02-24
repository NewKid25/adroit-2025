class_name ELEDialogInspector
extends PanelContainer

signal change_image
signal remove
signal edit_moodranges(am: float, aM: float, bm: float, bM: float, cm: float, cM: float)
signal edit_text(new_text: String)

func set_image(path: String):
	$HBoxContainer/TextureRect.texture = load("res://assets/art/%s" % path)

func set_text(text: String):
	$HBoxContainer/TextEdit.text = text

func set_moods(am, aM, bm, bM, cm, cM):
	$HBoxContainer/ScrollContainer/VBoxContainer/GridContainer/FlirtyMin.value = am
	$HBoxContainer/ScrollContainer/VBoxContainer/GridContainer/FlirtyMax.value = aM
	$HBoxContainer/ScrollContainer/VBoxContainer/GridContainer/FunnyMin.value = bm
	$HBoxContainer/ScrollContainer/VBoxContainer/GridContainer/FunnyMax.value = bM
	$HBoxContainer/ScrollContainer/VBoxContainer/GridContainer/SentimentMin.value = cm
	$HBoxContainer/ScrollContainer/VBoxContainer/GridContainer/SentimentMax.value = cM


func _on_change_image_pressed() -> void:
	change_image.emit()

func _on_remove_pressed() -> void:
	remove.emit()

func _on_mood_value_changed(_value: float) -> void:
	edit_moodranges.emit([
		$HBoxContainer/ScrollContainer/VBoxContainer/GridContainer/FlirtyMin.value,
		$HBoxContainer/ScrollContainer/VBoxContainer/GridContainer/FlirtyMax.value,
		$HBoxContainer/ScrollContainer/VBoxContainer/GridContainer/FunnyMin.value,
		$HBoxContainer/ScrollContainer/VBoxContainer/GridContainer/FunnyMax.value,
		$HBoxContainer/ScrollContainer/VBoxContainer/GridContainer/SentimentMin.value,
		$HBoxContainer/ScrollContainer/VBoxContainer/GridContainer/SentimentMax.value
	])


func _on_text_edit_text_changed() -> void:
	edit_text.emit($HBoxContainer/TextEdit.text)
