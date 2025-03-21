class_name HitboxComponent extends Area3D

signal attacked(attack: Attack)
signal detected_by_enemy

@export var id: String

var avg_entitiy_velocity: Vector3 = Vector3.ZERO

func damage(attack: Attack) -> void:
	attacked.emit(attack)
