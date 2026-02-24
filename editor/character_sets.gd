class_name ELECharacterSets
extends ScrollContainer

@warning_ignore("unused_signal")
signal click_left(setidx: int, dateidx: int)
@warning_ignore("unused_signal")
signal click_middle(setidx: int, dateidx: int)
@warning_ignore("unused_signal")
signal click_right(setidx: int, dateidx: int)
@warning_ignore("unused_signal")
signal click_edit_backgrounds(setidx: int, dateidx: int)
@warning_ignore("unused_signal")
signal click_add_date(setidx: int)

func add_set() -> ELECharacterSet:
	var n = preload("res://editor/character_set.tscn").instantiate()
	$VBoxContainer/OnlySets.add_child(n)
	return n

func set_bckgs(setid, dateid, b1, b2, b3):
	get_set(setid).set_bckgs(dateid, b1, b2, b3)

func set_profiles(setid, dateid, p1, p2, p3):
	get_set(setid).set_profiles(dateid, p1, p2, p3)

func set_name_data(setid, dateid, dn, n1, p1, n2, p2, n3, p3):
	get_set(setid).set_name_data(dateid, dn, n1, p1, n2, p2, n3, p3)

func add_date(setid) -> ELEDateListing:
	return get_set(setid).add_date()

func get_set(setid) -> ELECharacterSet:
	return $VBoxContainer/OnlySets.get_child(setid)
