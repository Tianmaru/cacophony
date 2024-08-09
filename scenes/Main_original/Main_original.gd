extends Spatial

onready var player = $Player
onready var monster = $Monster
onready var goal = $Goal
onready var grid_map = $GridMap
onready var blind = $CanvasLayer/ColorRect

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	player.grid_map = grid_map
	monster.player = player
	monster.grid_map = grid_map
	monster.astar = generate_astar()
	goal.player = player

func _process(delta):
	if Input.is_action_just_pressed("cheat"):
		blind.visible = not blind.visible

func generate_astar():
	var neighbors = [Vector3.FORWARD, Vector3.LEFT, Vector3.BACK, Vector3.RIGHT]
	var astar = AStar.new()
	for cell in grid_map.get_used_cells():
		if grid_map.get_cell_item(cell.x, cell.y, cell.z) == 1:
			astar.add_point(astar.get_available_point_id(), cell)
	for point in astar.get_points():
		var point_pos = astar.get_point_position(point)
		for n_vec in neighbors:
			var n_pos = point_pos + n_vec
			if grid_map.get_cell_item(n_pos.x, n_pos.y, n_pos.z) == 1:
				var n_id = astar.get_closest_point(n_pos)
				astar.connect_points(point, n_id)
	return astar

func _on_Player_echolocate():
	goal.ping()

func _on_Monster_player_catched():
	get_tree().change_scene("res://GameOver/GameOver.tscn")

func _on_Goal_goal_reached():
	get_tree().change_scene("res://YouWin/YouWin.tscn")
