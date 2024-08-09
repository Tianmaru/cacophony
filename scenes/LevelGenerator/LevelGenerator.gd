tool
class_name LevelGenerator
extends Spatial

const WALL_ID = 0
const FLOOR_ID = 1

const Y = 0

export(bool) var auto := true
export(bool) var generate := true setget set_generate
export(int) var map_size := 10
export(int) var n_rooms := 3
export(float) var p_room := 0.5
export(int) var min_room_size := 3
export(int) var max_room_size := 5

export(int) var STEPS = 300
export(int) var n_monsters := 1

export(Array, AudioStream) var audio_clues = []

var rooms : Array
var player
var goal
var monsters : Array
var astar : AStar

var player_scn = preload("res://scenes/Player/Player.tscn")
var goal_scn = preload("res://scenes/Goal/Goal.tscn")
var monster_scn = preload("res://scenes/Monster/Monster.tscn")

var wind_sfx = preload("res://audio/ambient/dungeon_ambient_1.ogg")

onready var grid_map : GridMap = $GridMap
onready var entities = $Entities
onready var audio = $Audio
onready var rooms_parent = $Rooms

# Called when the node enters the scene tree for the first time.
func _ready():
	if not Engine.editor_hint:
		if auto:
			print(map_size)
			generate_level()
		else:
			for child in entities.get_children():
				if child.is_in_group("player"):
					player = child
				elif child.is_in_group("goal"):
					goal = child
				elif child.is_in_group("monster"):
					monsters.append(child)
		set_up()

func generate_level():
	clean_up()
	generate_map()
	spawn_entities()
	spawn_audio()

func set_up():
	generate_astar()
	player.grid_map = grid_map
	player.random_orientation()
	goal.player = player
	goal.grid_map = grid_map
	goal.astar = astar
	for monster in monsters:
		monster.grid_map = grid_map
		monster.astar = astar
		monster.player = player

func clean_up():
	grid_map.clear()
	player = null
	goal = null
	monsters = []
	for e in entities.get_children():
		e.queue_free()
	for a in audio.get_children():
		a.queue_free()
	for r in rooms_parent.get_children():
		r.queue_free()

func spawn_entities():
	var exclude_rooms = []
	var exclude_positions = []
	player = player_scn.instance()
	add_node(player, entities)
	player.transform.origin = get_free_spawn_pos(exclude_rooms, exclude_positions)
	goal = goal_scn.instance()
	add_node(goal, entities)
	goal.transform.origin = get_free_spawn_pos(exclude_rooms, exclude_positions)
	for i in range(n_monsters):
		var monster = monster_scn.instance()
		add_node(monster, entities)
		monster.transform.origin = get_free_spawn_pos(exclude_rooms, exclude_positions)
		monsters.append(monster)

func create_room_area(room : Rect2):
	var room_area = Area.new()
	add_node(room_area, rooms_parent)
	var room_pos = grid_map.map_to_world(room.position.x, Y, room.position.y)
	room_pos.x += room.size.x / 2.0 - 0.5
	room_pos.z += room.size.y / 2.0 - 0.5
	room_area.transform.origin = room_pos
	#room_area.audio_bus_override = true
	#room_area.audio_bus_name = "Cave"
	room_area.reverb_bus_enable = true
	room_area.reverb_bus_name = "Cave"
	# room_area.reverb_bus_amount = min(room.get_area() / 36, 0.8)
	room_area.reverb_bus_amount = 0
	var room_col = CollisionShape.new()
	room_col.shape = BoxShape.new()
	room_col.shape.extents = Vector3(room.size.x / 2.0, 1, room.size.y / 2.0)
	add_node(room_col, room_area)

func spawn_audio():
	var exits = []
	for room in rooms:
		create_room_area(room)
		for e in get_exits(room):
			if not e in exits:
				exits.append(e)
				add_audio(wind_sfx, to_vector3(e))
	var exclude_rooms = []
	var exclude_positions = []
	for sfx in audio_clues:
		add_audio(sfx, get_free_spawn_pos(exclude_rooms, exclude_positions), 3)

func add_audio(stream, position, max_distance=0):
	var audio_player = AudioStreamPlayer3D.new()
	audio_player.stream = stream
	audio_player.autoplay = true
	audio_player.max_distance = max_distance
	audio_player.bus = "SFX"
	add_node(audio_player, audio)
	audio_player.transform.origin = position

func set_generate(value):
	generate = value
	if generate:
		generate_level()

func create_walker():
	var walker = Walker.new()
	walker.bounding_rect = Rect2(0,0, map_size, map_size)
	walker.n_rooms = n_rooms
	walker.p_room = p_room
	walker.min_room_size = min_room_size
	walker.max_room_size = max_room_size
	walker.reset()
	return walker

func generate_map():
	var walker = create_walker()
	var map = walker.walk(STEPS)
	rooms = walker.rooms
	#walker.free()
	for x in range(int(walker.bounding_rect.position.x) - 1, int(walker.bounding_rect.end.x) + 1):
		for z in range(int(walker.bounding_rect.position.y) - 1, int(walker.bounding_rect.end.y) + 1):
			grid_map.set_cell_item(x, Y, z, WALL_ID)
	for cell in map:
		grid_map.set_cell_item(int(cell.x), Y, int(cell.y), FLOOR_ID)

func get_spawn_room(exclude_rooms = []):
	var spawn_rooms = rooms.duplicate()
	if len(exclude_rooms) < len(spawn_rooms):
		for r in exclude_rooms:
			spawn_rooms.erase(r)
	spawn_rooms.shuffle()
	return spawn_rooms.pop_front()

func get_spawn_pos(spawn_room, exclude_positions=[]):
	var spawn_positions = get_floor_tiles(spawn_room)
	for p in exclude_positions:
		spawn_positions.erase(p)
	spawn_positions.shuffle()
	return to_vector3(spawn_positions.pop_front())

func get_floor_tiles(room : Rect2):
	var tiles = []
	var pos_x = int(room.position.x)
	var pos_z = int(room.position.y)
	for x in range(pos_x, pos_x + int(room.size.x)):
		for z in range(pos_z, pos_z + int(room.size.y)):
			if grid_map.get_cell_item(x, Y, z) == FLOOR_ID:
				tiles.append(Vector2(x, z))
	return tiles

func get_free_spawn_pos(exclude_rooms, exclude_positions):
	var spawn_room = get_spawn_room(exclude_rooms)
	exclude_rooms.append(spawn_room)
	var spawn_pos = get_spawn_pos(spawn_room, exclude_positions)
	exclude_positions.append(spawn_pos)
	return spawn_pos

func get_exits(room : Rect2):
	var exits = []
	var pos_x = int(room.position.x)
	var end_x = pos_x + int(room.size.x) - 1
	var pos_z = int(room.position.y)
	var end_z = pos_z + int(room.size.y) - 1
	for x in range(pos_x, end_x):
		for z in [pos_z - 1, end_z + 1]:
			if grid_map.get_cell_item(x, Y, z) == FLOOR_ID:
				exits.append(Vector2(x, z))
	for x in [pos_x - 1, end_x + 1]:
		for z in range(pos_z, end_z):
			if grid_map.get_cell_item(x, Y, z) == FLOOR_ID:
				exits.append(Vector2(x, z))
	return exits

func to_vector3(vec2 : Vector2) -> Vector3:
	return Vector3(vec2.x, Y, vec2.y)

func add_node(node, parent):
	parent.add_child(node)
	if Engine.editor_hint:
		node.owner = get_tree().edited_scene_root

func generate_astar():
	var neighbors = [Vector3.FORWARD, Vector3.LEFT, Vector3.BACK, Vector3.RIGHT]
	astar = AStar.new()
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
