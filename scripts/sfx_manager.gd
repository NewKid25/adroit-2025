extends Node

func play_sound(stream:AudioStream):
	var player:AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = stream
	player.bus = "Sfx"
	add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
