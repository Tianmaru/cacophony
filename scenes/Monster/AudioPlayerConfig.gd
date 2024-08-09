tool
class_name AudioPlayerConfig
extends Spatial

export(bool) var update = false setget set_update

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_update(value):
	update = value
	var audio_players = get_children()
	var template = audio_players.pop_front()
	for p in audio_players:
		for property in template.get_property_list():
			if property["name"] != "stream" and property["name"] != "name":
				p.set(property["name"], template.get(property["name"]))
	print("audio players updated")
