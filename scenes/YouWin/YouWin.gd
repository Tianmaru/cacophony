extends Control

onready var audio_player = $AudioStreamPlayer
onready var anim = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(false)
	audio_player.connect("finished", anim, "play", ["escape"])

func _input(event):
	if event is InputEventKey or event is InputEventMouseButton:
		if event.is_pressed():
			get_tree().change_scene("res://scenes/Title/Title.tscn")


func _on_AnimationPlayer_animation_finished(anim_name):
	set_process_input(true)
