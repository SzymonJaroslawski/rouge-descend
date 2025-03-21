class_name PlayerDetectionComponent extends Node3D

signal enemy_detected(enemy: CharacterBody3D)
signal enemy_lost

@export_category("Nodes")
@export var detection_area: VisionCone3D
@export var detection_raycast: RayCast3D

@export_category("Parameters")
@export var detection_raycast_minus_z: float
@export var detection_timer_wait_time: float

var speed: float
var last_detected_enemy_rid: RID

func _ready() -> void:
	detection_raycast.target_position = Vector3(0.0,0.0,detection_raycast_minus_z)
	detection_area.body_sighted.connect(check_detection)
	detection_area.body_hidden.connect(lost_enemy)

func lost_enemy(body: Node3D) -> void:
	if body.get_rid() == last_detected_enemy_rid:
		last_detected_enemy_rid = RID()
		enemy_lost.emit()

func check_detection(body: Node3D) -> void:
	if body is Player:
		last_detected_enemy_rid = body.get_rid()
		enemy_detected.emit(body)
