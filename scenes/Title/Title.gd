extends Node2D

var main_scn = preload("res://scenes/Main/Main.tscn")

onready var play_btn = $CanvasLayer/VBoxContainer/PlayButton
onready var howto_btn = $CanvasLayer/VBoxContainer/HowToButton
onready var credits_btn = $CanvasLayer/VBoxContainer/CreditsButton

onready var play_popup = $CanvasLayer/PlayPopup
onready var howto_popup = $CanvasLayer/HowToPlayPopup
onready var credits_popup = $CanvasLayer/CreditsPopup
onready var settings_popup = $CanvasLayer/SettingsPopup

# Called when the node enters the scene tree for the first time.
func _ready():
	play_btn.grab_focus()
	play_popup.connect("custom_action", self, "start_game")

func start_game(difficulty):
	Global.new_seed()
	if difficulty == "Easy":
		Global.difficulty = Global.Difficulty.EASY
	elif difficulty == "Normal":
		Global.difficulty = Global.Difficulty.NORMAL
	elif difficulty == "Hard":
		Global.difficulty = Global.Difficulty.HARD
	get_tree().change_scene_to(main_scn)

func _on_PlayButton_button_up():
	play_popup.popup()

func _on_CreditsButton_button_up():
	credits_popup.popup()

func _on_HowToButton_button_up():
	howto_popup.popup()

func _on_SettingsButton_button_up():
	settings_popup.popup()
