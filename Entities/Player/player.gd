class_name Player extends CharacterBody3D

#region Player components
@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var camera: Camera3D = $Camera
#endregion

#region Movement state
@export var max_speed: float
@export var accel: float
@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var avg_entitiy_velocity := Vector3.ZERO
var direction := Vector3.ZERO
var current_speed := 0.0
#endregion

#region Input vars
@onready var mouse_sense: float = ProjectSettings.get_setting("game/input/mouse_sensitivity")
var input_dir: Vector2
#endregion

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

#region Game logic components
func _on_hitbox_component_attacked(attack: Attack) -> void:
	health_component.damage(attack)

func _on_health_component_health_reached_zero() -> void:
	print("Died")
	get_tree().quit()
#endregion

#region Movement and input
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		event = event as InputEventMouseMotion
		rotate_y(-event.relative.x * mouse_sense)
		camera.rotate_x(-event.relative.y * mouse_sense)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y -= gravity * delta
	_handle_movement(delta)
	move_and_slide()

func _handle_movement(delta: float) -> void:
	input_dir = Input.get_vector("left", "right", "forward", "back")
	
	direction = transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	var target_speed := max_speed
	
	if direction != Vector3.ZERO:
		current_speed = move_toward(current_speed, target_speed, accel * delta)
	else:
		current_speed = move_toward(current_speed, 0, (accel * 100.0) * delta)
	
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed
#endregion
