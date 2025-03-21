class_name ChaseComponent extends NavigationAgent3D

signal navigate(new_pos: Vector3)
signal stop_navigating

@export var p_desired_distance: float
@export var t_desired_distance: float
@export var velocity_tracking_infulance: float

@export var predictive_movement: bool = true
@export var velocity_queue_max_size: int
@export var velocity_queue_max_age_ms: float

var velocity_queue: VelocityQueueRefCounted

var target: Node3D
var global_position: Vector3
var enemy_velocity: Vector3

var _tracking_velocity: bool = false

func _ready() -> void:
	path_desired_distance = p_desired_distance
	target_desired_distance = t_desired_distance
	
	if predictive_movement:
		velocity_queue = VelocityQueueRefCounted.new()
		velocity_queue.max_queue_size = velocity_queue_max_size
		velocity_queue.max_age_ms = velocity_queue_max_age_ms
	
	_setup.call_deferred()

func _setup() -> void:
	await get_tree().physics_frame

func _on_enemy_detected(enemy: Node3D) -> void:
	target = enemy
	if enemy.is_in_group("velocity_trackable") and predictive_movement:
		_tracking_velocity = true
		velocity_queue.velocity_parent = enemy

func _on_enemy_lost() -> void:
	velocity_queue.clear_queue()
	velocity_queue.velocity_parent = null
	_tracking_velocity = false
	target = null

func _physics_process(_delta: float) -> void:
	if target:
		target_position = target.global_position
	
	if target and _tracking_velocity:
		velocity_queue.add_velocity()
		
		var _dot := target.global_position.dot(target.global_position + (velocity_queue.get_avg() * velocity_tracking_infulance))
		
		if _dot > 0:
			target_position = target.global_position
		
		if _dot < 0:
			target_position = target.global_position + (velocity_queue.get_avg() * velocity_tracking_infulance)
	
	if is_navigation_finished():
		stop_navigating.emit()
		return
	
	var direction := (get_next_path_position() - global_position).normalized()
	navigate.emit(direction)
