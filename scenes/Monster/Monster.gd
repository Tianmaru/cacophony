extends Area

signal step_taken
signal player_catched

const FREE_CELL = 1
export(float) var P_RANDOM_STEP = 0.1

export(float) var SPEED = 0.5

var grid_map : GridMap setget set_grid_map
var astar : AStar
var player

var is_moving := false setget set_is_moving
var target_position
var sleeping := false setget set_sleeping

onready var sfx_distant = $sfx_distant
onready var sfx_closer = $sfx_closer
onready var sfx_near = $sfx_near
onready var timer = $Timer
onready var sfx_distant_timer = $SfxDistantTimer
onready var sfx_closer_timer = $SfxCloserTimer
onready var sfx_near_timer = $SfxNearTimer

var sfx_distant_config = {
	"attenuation_model": AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE,
	"max_distance": 5,
	"unit_db": 30,
	"bus": "Voice",
}

var sfx_closer_config = {
	"attenuation_model": AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE,
	"max_distance": 3,
	"unit_db": 30,
	"bus": "Voice",
}

var sfx_near_config = {
	"attenuation_model": AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE,
	"max_distance": 3,
	"unit_db": 30,
	"bus": "Voice",
}

var directions := [Vector3.FORWARD, Vector3.LEFT, Vector3.BACK, Vector3.RIGHT]

func _ready():
	set_sfx_config(sfx_distant, sfx_distant_config)
	set_sfx_config(sfx_closer, sfx_closer_config)
	set_sfx_config(sfx_near, sfx_near_config)

func set_sleeping(value : bool):
	sleeping = value
	#timer.paused = sleeping
	set_physics_process(not sleeping)

func get_next_step():
	var grid_pos = grid_map.world_to_map(transform.origin)
	var monster_id = astar.get_closest_point(grid_pos)
	var player_grid_pos = grid_map.world_to_map(player.transform.origin)
	var player_id = astar.get_closest_point(player_grid_pos)
	var path = astar.get_point_path(monster_id, player_id)
	if rand_range(0,1) < P_RANDOM_STEP or not len(path) > 1:
		target_position = transform.origin + directions[randi() % len(directions)]
	else:
		var next_point = path[1]
		target_position = grid_map.map_to_world(next_point.x, next_point.y, next_point.z)
	var new_grid_pos = grid_map.world_to_map(target_position)
	if grid_map.get_cell_item(new_grid_pos.x, new_grid_pos.y, new_grid_pos.z) == FREE_CELL:
		self.is_moving = true

func _physics_process(delta):
	if is_moving:
		var dir_vec = target_position - transform.origin
		if dir_vec.length() <= SPEED * delta:
			self.is_moving = false
			transform.origin = target_position
			emit_signal("step_taken")
			timer.wait_time = rand_range(0,1)
			timer.start()
		else:
			transform.origin += dir_vec.normalized() * SPEED * delta

func set_is_moving(value):
	set_physics_process(not value)
	is_moving = value

func set_grid_map(value):
	grid_map = value
	var grid_pos = grid_map.world_to_map(transform.origin)
	transform.origin = grid_map.map_to_world(grid_pos.x, grid_pos.y, grid_pos.z)

func _on_Timer_timeout():
	get_next_step()
	if not is_moving:
		timer.start()

func set_sfx_config(sfx, config):
	for sound in sfx.get_children():
		for key in config:
			sound.set(key, config[key])

func play_random(sfx):
	var sounds = sfx.get_children()
	var sound = sounds[randi() % len(sounds)]
	if not sound.playing:
		sound.pitch_scale = rand_range(0.8,1.2)
		sound.play()

func restart_sfx_timer(sfx_timer, t_min=0, t_max=1):
	sfx_timer.wait_time = rand_range(t_min,t_max)
	sfx_timer.start()

func _on_SfxDistantTimer_timeout():
	play_random(sfx_distant)
	restart_sfx_timer(sfx_distant_timer, 2,4)


func _on_SfxCloserTimer_timeout():
	play_random(sfx_closer)
	restart_sfx_timer(sfx_closer_timer,1,2)

func _on_SfxNearTimer_timeout():
	play_random(sfx_near)
	restart_sfx_timer(sfx_near_timer,0,2)

func stop_sfx():
	sfx_near_timer.stop()
	sfx_closer_timer.stop()
	sfx_near_timer.stop()

func _on_Monster_body_entered(body):
	emit_signal("player_catched")
