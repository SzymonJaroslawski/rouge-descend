class_name Room extends Node3D

@export var room_id: String
@export var collision_detector: CollisionDetector

var connection_points: Array[Marker3D]
var used_connections: Array[Marker3D]

func _ready() -> void:
	for child in find_child("Markers").get_children():
		if child.is_class("Marker3D"):
			connection_points.append(child)
