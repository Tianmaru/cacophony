extends Area

signal goal_reached

export(Array, AudioStream) var audio_streams = []

var player
var grid_map : GridMap
var astar : AStar

#var echo_scn = preload("res://scenes/Echo/Echo.tscn")
var flood_fill_sound_scn = preload("res://scenes/FloodFillSound/FloodFillSound.tscn")

func ping():
	var ffs = flood_fill_sound_scn.instance()
	ffs.listener = player
	ffs.grid_map = grid_map
	if not audio_streams.empty():
		ffs.stream = audio_streams[randi() % len(audio_streams)]
	ffs.bus_name = "Voice"
	add_child(ffs)
	print("startet ffs")

func _on_Goal_body_entered(body):
	emit_signal("goal_reached")
