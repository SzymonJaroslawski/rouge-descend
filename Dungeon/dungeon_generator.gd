class_name DungeonGenerator extends Node3D

@export var generation_target: Node
@export var first_room: PackedScene

var max_rooms: int
var rooms: Array[Room]

var adjacency_rules: Dictionary[String, Array] = {
	"room_small": ["hallway"],
	"hallway": ["room_small", "room_big", "room_knee_l", "hallway"],
	"room_big": ["hallway"],
	"room_knee_l": ["hallway", "room_small", "room_big"],
}

var adjacency_chance: Dictionary[String, Array] = {
	"room_small": [1.0],
	"hallway": [0.05, 0.10, 0.15, 0.7],
	"room_big": [1.0],
	"room_knee_l": [0.15, 0.25, 0.6],
}

func generate() -> void:
	var start_room: Room = first_room.instantiate()
	generation_target.add_child(start_room)
	rooms.append(start_room)

	var room_queue: Array[Dictionary]

	for point in start_room.connection_points:
		room_queue.append({
			"room": start_room,
			"connection_point": point,
		})
	
	await _procces_room_queue(room_queue)
	
func _procces_room_queue(room_queue: Array[Dictionary]) -> void:
	while rooms.size() < max_rooms and !room_queue.is_empty():
		var index := randi() % room_queue.size()
		var current := room_queue[index]

		var current_room: Room = current["room"]
		var current_point: Marker3D = current["connection_point"]

		if current_room.used_connections.has(current_point):
			continue
		
		var parent_id: String = current_room.room_id
		
		var cummulative_prob: Array[float] = []
		var sum: float = 0.0

		for prob in adjacency_chance[parent_id]:
			sum += prob
			cummulative_prob.append(sum)
		
		var rng = randf() * sum
		
		var new_room_id: String
		
		var i = 0
		
		for v in cummulative_prob:
			if rng <= v:
				new_room_id = adjacency_rules[parent_id][i]
				i += 1
		
		if await _try_placing_room(current_room, current_point, new_room_id, room_queue):
			current_room.used_connections.append(current_point)
			room_queue.remove_at(index)

func _try_placing_room(current_room: Room, current_point: Marker3D, new_room_id: String, room_queue: Array[Dictionary]) -> bool:
	var room_scene: PackedScene = load("res://Dungeon/Rooms/%s.tscn" % new_room_id)
	var new_room: Room = room_scene.instantiate()

	generation_target.add_child(new_room)

	for new_point in new_room.connection_points:
		_aligin_room(current_room, current_point, new_room, new_point)

		if await _check_room_collision(new_room):
			new_room.queue_free()
			return false
		
		rooms.append(new_room)
		new_room.used_connections.append(new_point)

		for point in new_room.connection_points:
			if !new_room.used_connections.has(point):
				room_queue.append({
					"room": new_room,
					"connection_point": point,
				})
	
		return true
	
	new_room.queue_free()
	return false

func _aligin_room(parent_room: Room ,parent_point: Marker3D, new_room: Room, new_point: Marker3D):
	var parent_global_pos := parent_room.to_global(parent_point.position)
	var parent_forward := -parent_point.global_transform.basis.z
	
	var new_forward = -new_point.global_transform.basis.z

	var rotation_basis = Basis.looking_at(-parent_forward, Vector3.UP)
	var new_basis = Basis.looking_at(new_forward, Vector3.UP)
	var final_basis = rotation_basis * new_basis.inverse()
	
	new_room.global_transform.basis = final_basis
	
	var offset := parent_global_pos - new_room.to_global(new_point.position)
	
	new_room.global_transform.origin += offset

func _check_room_collision(room: Room) -> bool:
	await get_tree().physics_frame
	await get_tree().physics_frame
	return room.collision_detector.collides
