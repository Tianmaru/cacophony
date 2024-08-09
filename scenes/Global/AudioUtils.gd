extends Node

func on_sound_finished(audio_player):
	audio_player.queue_free()

func create_audio_player(parent, stream, bus_name="Master"):
	var audio_player = AudioStreamPlayer3D.new()
	audio_player.stream = stream
	audio_player.bus = bus_name
	parent.add_child(audio_player)
	audio_player.connect("finished", self, "on_sound_finished", [audio_player])
	audio_player.play()

func play_random_sound(parent, audio_streams, bus_name="Master"):
	if audio_streams.empty():
		return
	var stream = audio_streams[randi() % len(audio_streams)]
	create_audio_player(parent, stream, bus_name)
