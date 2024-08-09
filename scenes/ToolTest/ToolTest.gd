tool
extends Control

export(String) var text = "tool test" setget set_text

onready var label = $Label

# Called when the node enters the scene tree for the first time.
func _ready():
	print("ready")

func set_text(value : String):
	print("text set to %s" % value)
	text = value
	if label:
		label.text = text
