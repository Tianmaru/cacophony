extends Control

onready var anim = $AnimationPlayer
onready var audio_player = $AudioStreamPlayer
onready var retry_btn = $VBoxContainer/HBoxContainer/MenuButton
onready var menu_btn = $VBoxContainer/HBoxContainer/RetryButton

# Called when the node enters the scene tree for the first time.
func _ready():
	retry_btn.grab_focus()
	audio_player.connect("finished", anim, "play", ["fade_in"])

func _on_MenuButton_button_up():
	get_tree().change_scene("res://scenes/Title/Title.tscn")

func _on_RetryButton_button_up():
	get_tree().change_scene("res://scenes/Main/Main.tscn")
