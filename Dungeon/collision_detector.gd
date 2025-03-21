class_name CollisionDetector extends Area3D

var collides := false

func _ready() -> void:
	Global.generation_finished.connect(func () -> void:
		set_physics_process(false)
	)

func _physics_process(_delta: float) -> void:
	collides = has_overlapping_areas()
