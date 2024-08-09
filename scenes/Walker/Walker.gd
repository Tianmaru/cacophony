class_name Walker
extends Resource

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

var position : Vector2
var direction : Vector2
var step_history : Array
var steps_since_turn : int
export(Rect2) var bounding_rect : Rect2

export(int) var STEPS_PER_TURN := 6
export(int) var min_room_size := 3
export(int) var max_room_size := 5
export(float) var p_room := 0.5
export(int) var n_rooms := 3
var rooms : Array

func reset(create_start_room=true):
	position = Vector2()
	position.x = bounding_rect.position.x + randi() % int(bounding_rect.size.x)
	position.y = bounding_rect.position.y + randi() % int(bounding_rect.size.y)
	rooms = []
	direction = DIRECTIONS[randi() % len(DIRECTIONS)]
	step_history = [position]
	steps_since_turn = 0
	if create_start_room:
		create_room()

func walk(steps):
	for i in range(steps):
		if steps_since_turn >= STEPS_PER_TURN:
			change_direction()
		if step():
			step_history.append(position)
		else:
			change_direction()
		if n_rooms > 0 and len(rooms) >= n_rooms:
			break
	return step_history

func step():
	var new_position = position + direction
	if bounding_rect.has_point(new_position):
		position = new_position
		steps_since_turn += 1
		return true
	return false

func change_direction():
	if randf() <= p_room:
		create_room()
	steps_since_turn = 0
	var directions = DIRECTIONS.duplicate()
	directions.erase(direction)
	directions.erase(direction * -1)
	directions.shuffle()
	direction = directions.pop_front()
	while not bounding_rect.has_point(position + direction):
		direction = directions.pop_front()

func create_room():
	var size_x = randi() % (max_room_size - min_room_size) + min_room_size
	var size_y = randi() % (max_room_size - min_room_size) + min_room_size
	var room_size = Vector2(size_x, size_y)
	var room_pos = position - Vector2(size_x / 2, size_y / 2).floor()
	var room = Rect2(room_pos, room_size)
	for x in range(size_x):
		for y in range(size_y):
			var cell_pos = room_pos + Vector2(x,y)
			if bounding_rect.has_point(cell_pos):
				step_history.append(cell_pos)
	var merged_room = bounding_rect.clip(room)
	var new_rooms = []
	for r in rooms:
		var r_h = r.grow_individual(1,0,1,0)
		var r_v = r.grow_individual(0,1,0,1)
		if room.intersects(r_h) or room.intersects(r_v):
			merged_room = merged_room.merge(r)
		else:
			new_rooms.append(r)
	new_rooms.append(merged_room)
	rooms = new_rooms
