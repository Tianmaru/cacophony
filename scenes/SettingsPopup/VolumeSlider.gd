tool
extends VBoxContainer

export(String) var bus_name = "Master" setget set_bus_name
export(AudioStream) var audio_stream

var bus_idx : int

onready var label = $Label
onready var slider = $HSlider
onready var audio_player = $AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	init()

func init():
	bus_idx = AudioServer.get_bus_index(bus_name)
	label.text = bus_name
	slider.value = db2linear(AudioServer.get_bus_volume_db(bus_idx))
	audio_player.stream = audio_stream
	audio_player.bus = bus_name

func _on_HSlider_value_changed(value):
	AudioServer.set_bus_volume_db(bus_idx, linear2db(value))
	if audio_stream:
		audio_player.play()

func set_bus_name(value):
	bus_name = value
	if label and slider and audio_player:
		init()
