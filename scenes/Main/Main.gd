extends Spatial

onready var level : LevelGenerator = $LevelGenerator
onready var blind = $CanvasLayer/ColorRect

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.reset_rng()
	set_levelgen_params()
	level.generate_level()
	level.set_up()
	level.player.connect("called", self, "_on_Player_called")
	level.player.connect("intro_finished", self, "_on_Player_intro_finished")
	level.goal.connect("goal_reached", self, "_on_Goal_goal_reached")
	for monster in level.monsters:
		# monster.connect("player_catched", self, "_on_Monster_player_catched")
		monster.sleeping = true
	level.player.start_intro()

func _process(delta):
	if Input.is_action_just_pressed("cheat"):
		blind.visible = not blind.visible

func _on_Player_called():
	level.goal.ping()

func _on_Player_intro_finished():
	for monster in level.monsters:
		monster.connect("player_catched", self, "_on_Monster_player_catched")
		monster.sleeping = false

func _on_Monster_player_catched():
	get_tree().change_scene("res://scenes/GameOver/GameOver.tscn")

func _on_Goal_goal_reached():
	get_tree().change_scene("res://scenes/YouWin/YouWin.tscn")

func set_levelgen_params():
	if Global.difficulty == Global.Difficulty.EASY:
		level.n_monsters = 0
		level.n_rooms = 3
		level.p_room = 0.6
		level.map_size = 10
	elif Global.difficulty == Global.Difficulty.NORMAL:
		level.n_monsters = 1
		level.n_rooms = 5
		level.p_room = 0.5
		level.map_size = 30
	elif Global.difficulty == Global.Difficulty.HARD:
		level.n_monsters = 2
		level.n_rooms = 7
		level.p_room = 0.4
		level.max_room_size = 7
		level.map_size = 50
