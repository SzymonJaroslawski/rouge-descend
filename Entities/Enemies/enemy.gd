class_name Enemy extends CharacterBody3D

@export var stats: EnemyStats
@export var gravity_affected: bool

#region Enemy components
@export_category("Components")
@export var health_component: HealthComponent
@export var hitbox_component: HitboxComponent
@export var player_detection_component: PlayerDetectionComponent
@export var chase_component: ChaseComponent
#endregion

var new_position: Vector3 = Vector3.ZERO

var should_navigate: bool = false

func _ready() -> void:
	health_component.health = stats.health
	player_detection_component.enemy_detected.connect(chase_component._on_enemy_detected)
	player_detection_component.enemy_lost.connect(chase_component._on_enemy_lost)
	chase_component.navigate.connect(_on_got_target_pos)
	chase_component.navigation_finished.connect(_navigation_finished)

func _on_got_target_pos(_new_position: Vector3) -> void:
	should_navigate = true
	new_position = _new_position

func _navigation_finished() -> void:
	should_navigate = false

func _physics_process(delta: float) -> void:
	if gravity_affected:
		if !is_on_floor():
			velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
	chase_component.global_position = global_position
	
	var _target_rot := atan2(-new_position.x, -new_position.z)
	var _new_rot := lerp_angle(global_rotation.y, _target_rot, smoothstep(0.0, 1.0, delta * 16))
	global_rotation.y = _new_rot
	
	if !should_navigate:
		return
	
	velocity.x = move_toward(velocity.x, new_position.x * stats.speed, delta * stats.accel)
	velocity.z = move_toward(velocity.z, new_position.z * stats.speed, delta * stats.accel)
	
	move_and_slide()
