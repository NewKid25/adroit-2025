extends Control

@onready
var gui: ELEGui = $CharacterList/ELEGui
var testtest := false

var changedval

func _ready():
	get_window().content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED

func _CharacterList_gui(_delta: float):
	gui.label("Hello world!")
	
	if gui.button("Test button"):
		gui.label("whatever dude")
	
	testtest = gui.toggle("toggler", testtest)
	if testtest:
		gui.label("blah blah blah")
	
	gui.scroll()
	gui.expandbox_vert()
	gui.vbox()
	
	for i in range(20):
		gui.hbox()
		gui.texturerect(preload("res://assets/art/cassandra.png"))
		gui.button("Btn %d" % i)
		gui.end()
	
	gui.end()
	gui.end()

func did_change(new, old):
	changedval = new
	return new != old
