extends Spatial

const WALL_ID = 0
const FLOOR_ID = 1

export(float) var SPEED = 10.0
export(AudioStream) var stream = null
export(String) var bus_name = "Master"

var grid_map : GridMap
var listener

var flooded := []
var next := []
var propagation_distance := 0
var propagation_complete := false

var sound_player_scn = preload("res://scenes/FloodFillSound/SoundPlayer3D.tscn")

onready var timer : Timer = $PropagationTimer
onready var propagation_map : GridMap = $PropagationMap
onready var sound_players = $SoundPlayers

func _ready():
	next = [grid_map.world_to_map(global_transform.origin)]
	timer.wait_time = 1.0 / SPEED

func _process(delta):
	if propagation_complete and sound_players.get_child_count() == 0:
		queue_free()

func _physics_process(delta):
	if next.empty():
		propagation_complete = true
		set_physics_process(false)
		return
	var space_state = get_world().direct_space_state
	var neighbors = []
	while not next.empty():
		var cell = next.pop_front()
		flooded.append(cell)
		var cell_position = grid_map.to_global(grid_map.map_to_world(cell.x, cell.y, cell.z))
		var prop_map_cell = propagation_map.world_to_map(propagation_map.to_local(cell_position))
		var result = space_state.intersect_ray(cell_position, listener.global_transform.origin, [], 1)
		if result.empty():
			propagation_map.set_cell_item(prop_map_cell.x, prop_map_cell.y, prop_map_cell.z, 1)
			create_sound_player(cell_position)
		else:
			propagation_map.set_cell_item(prop_map_cell.x, prop_map_cell.y, prop_map_cell.z, 0)
			for v in [Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK]:
				var neighbor = cell + v
				if not grid_map.get_cell_item(neighbor.x, neighbor.y, neighbor.z) == WALL_ID:
					if not neighbor in flooded and not neighbor in neighbors:
						neighbors.append(neighbor)
	next = neighbors
	propagation_distance += 1
	set_physics_process(false)
	timer.start()

func create_sound_player(position : Vector3):
	var sound_player = sound_player_scn.instance()
	sound_player.stream = stream
	sound_player.bus = bus_name
	var db = linear2db(1.0 /(1.0 + propagation_distance))
	sound_player.unit_db = max(db, -20)
	print("DB: ", sound_player.unit_db)
	sound_player.delay = position.distance_to(listener.global_transform.origin) / SPEED
	sound_players.add_child(sound_player)
	sound_player.global_transform.origin = position

func _on_Timer_timeout():
	set_physics_process(true)
