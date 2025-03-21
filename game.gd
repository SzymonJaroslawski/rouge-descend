extends Node

@export var rooms: int
@export var player_scene: PackedScene

@onready var dungeon_generator: DungeonGenerator = $DungeonGenerator
@onready var physics_ticks: int = ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
@onready var camera_3d: Camera3D = $Camera3D

func _ready() -> void:
	dungeon_generator.max_rooms = rooms
	_setup.call_deferred()

func _setup() -> void:
	# Increase physics ticks for faster dungeon generation
	Engine.physics_ticks_per_second = physics_ticks * 20
	await dungeon_generator.generate()
	Global.generation_finished.emit()
	Engine.physics_ticks_per_second = physics_ticks
	#_spawn_player()

func _spawn_player() -> void:
	camera_3d.queue_free()
	var player: Player = player_scene.instantiate()
	add_child(player)
	player.global_position += Vector3(0.0, 1.0, 0.0)
