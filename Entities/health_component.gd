class_name HealthComponent extends Node3D

signal health_reached_zero

@export var health: float

func damage(attack: Attack) -> void:
	health -= attack.damage
	if health <= 0.0:
		health_reached_zero.emit()
