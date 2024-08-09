extends AudioStreamPlayer3D

const SPEED = 10
const MIN_DB = -40

var player : KinematicBody
var grid_map : GridMap
var astar : AStar

onready var ray = $RayCast 
onready var timer = $Timer

var next_position : Vector3
var total_propagation : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	next_position = global_transform.origin
	update_raycast()
	ray.force_raycast_update()

func _physics_process(delta):
	if not ray.is_colliding():
		set_physics_process(false)
		#unit_db = max(MIN_DB, -1 * pow(total_propagation, 2))
		timer.wait_time = global_transform.origin.distance_to(player.global_transform.origin) / SPEED
		timer.start()
	else:
		if not next_position or global_transform.origin.distance_to(next_position) <= SPEED * delta:
			global_transform.origin = next_position
			total_propagation += global_transform.origin.distance_to(next_position)
			var echo_id = astar.get_closest_point(grid_map.world_to_map(global_transform.origin))
			var player_id = astar.get_closest_point(grid_map.world_to_map(player.global_transform.origin))
			var path = astar.get_point_path(echo_id, player_id)
			if len(path) > 1:
				next_position = grid_map.map_to_world(path[1].x, path[1].y, path[1].z)
		else:
			var propagation = global_transform.origin.direction_to(next_position) * SPEED * delta
			global_transform.origin += propagation
			total_propagation += propagation.length()
		update_raycast()

func update_raycast():
	ray.cast_to = player.global_transform.origin - global_transform.origin

func _on_Echo_finished():
	print("finished")
	queue_free()

func _on_Timer_timeout():
	play()
