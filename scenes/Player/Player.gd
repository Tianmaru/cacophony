extends KinematicBody

signal step_taken
signal turned
signal called
signal intro_finished

const FREE_CELL = 1


export(float) var SPEED = 4
export(float) var TURN_SPEED = 2*PI

export(Array, AudioStream) var step_sounds = []
export(Array, AudioStream) var call_sounds = []

var grid_map : GridMap setget set_grid_map

var is_moving := false setget set_is_moving
var target_position
var is_turning := false setget set_is_turning
var target_rotation
var turn_dir := 0

onready var voice_calls = $Voice/Calls
onready var voice_intro = $Voice/intro
onready var sfx_steps = $sfx/steps
onready var sfx_bump = $sfx/bump
onready var sfx_step = $sfx/step
onready var sfx_ping = $sfx/ping
onready var sfx_left = $sfx/left
onready var sfx_right = $sfx/right

var orientation := 0
var orientations := [Vector3.FORWARD, Vector3.LEFT, Vector3.BACK, Vector3.RIGHT]
# Called when the node enters the scene tree for the first time.

func _ready():
	orientation = int(rotation_degrees.y / 90) % len(orientations)
	rotation_degrees.y = orientation * 90.0

func _process(delta):
	if Input.is_action_just_pressed("move_forward"):
		var grid_pos = grid_map.world_to_map(transform.origin)
		var new_grid_pos = grid_pos + orientations[orientation]
		if grid_map.get_cell_item(new_grid_pos.x, new_grid_pos.y, new_grid_pos.z) == FREE_CELL:
			target_position = grid_map.map_to_world(new_grid_pos.x, new_grid_pos.y, new_grid_pos.z)
			self.is_moving = true
			AudioUtils.play_random_sound(sfx_steps, step_sounds, "SFX")
		else:
			sfx_bump.play()
	elif Input.is_action_just_pressed("turn_left"):
		orientation = (orientation + 1) % 4
		target_rotation = fmod(orientation * PI/2, 2 * PI)
		turn_dir = 1
		is_turning = true
		sfx_left.play()
	elif Input.is_action_just_pressed("turn_right"):
		orientation = (orientation - 1) % 4
		target_rotation = fmod(orientation * PI/2, 2 * PI)
		turn_dir = -1
		is_turning = true
		sfx_right.play()
	elif Input.is_action_just_pressed("call"):
		if voice_intro.playing:
			voice_intro.stop()
			emit_signal("intro_finished")
		emit_signal("called")
		AudioUtils.play_random_sound(sfx_steps, call_sounds, "SFX")

func _physics_process(delta):
	if is_turning:
		if abs(fmod(target_rotation - rotation.y, 2 * PI)) <= TURN_SPEED * delta:
			rotation.y = target_rotation
			is_turning = false
			emit_signal("turned")
		else:
			rotation.y += turn_dir * TURN_SPEED * delta
	if is_moving:
		var dir_vec = target_position - transform.origin
		if dir_vec.length() <= SPEED * delta:
			self.is_moving = false
			transform.origin = target_position
			emit_signal("step_taken")
		else:
			move_and_slide(dir_vec.normalized() * SPEED)

func set_is_moving(value):
	set_process(not value)
	is_moving = value

func set_is_turning(value):
	set_process(not value)
	is_turning = value

func set_grid_map(value):
	grid_map = value
	var grid_pos = grid_map.world_to_map(transform.origin)
	transform.origin = grid_map.map_to_world(grid_pos.x, grid_pos.y, grid_pos.z)

func random_orientation():
	orientation = (orientation + 1) % 4
	target_rotation = fmod(orientation * PI/2, 2 * PI)
	self.rotation.y = target_rotation

func start_intro():
	voice_intro.connect("finished", self, "on_intro_finished")
	voice_intro.play()

func on_intro_finished():
	emit_signal("intro_finished")
	emit_signal("called")
