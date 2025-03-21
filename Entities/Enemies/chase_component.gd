class_name ChaseComponent extends NavigationAgent3D

signal navigate(new_pos: Vector3)
signal stop_navigating

@export var p_desired_distance: float
@export var t_desired_distance: float
@export var velocity_tracking_infulance: float

@export var predictive_movement: bool = true
@export var velocity_queue_max_size: int
@export var velocity_queue_max_age_ms: float
@export var movement_predictive_treshold: float = 0.33

var velocity_queue: VelocityQueueRefCounted

var target: Node3D
var global_position: Vector3
var parent_velocity: Vector3
var enemy_velocity: Vector3

var searching: bool = false
var search_points: Array[Vector3]
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

func _on_start_search(_search_points: Array[Vector3]) -> void:
	search_points = _search_points
	searching = true

func _on_enemy_detected(enemy: Node3D) -> void:
	target = enemy
	searching = false
	if enemy.is_in_group("velocity_trackable") and predictive_movement:
		_tracking_velocity = true
		velocity_queue.velocity_parent = enemy

func _on_enemy_lost() -> void:
	_tracking_velocity = false
	velocity_queue.clear_queue()
	velocity_queue.velocity_parent = null
	target = null

func _physics_process(_delta: float) -> void:
	if target:
		target_position = target.global_position
	
	if target and _tracking_velocity:
		velocity_queue.add_velocity()
		
		var _target_dir := target.global_position + (velocity_queue.get_avg() * velocity_tracking_infulance)
		
		var dir_to_target := (_target_dir - global_position).normalized()
		var dir_to_enemy := (target.global_position - global_position).normalized()
		
		var dot: float = dir_to_enemy.dot(dir_to_target)
		
		if dot < movement_predictive_treshold:
			debug_path_custom_color = Color.GREEN
			_target_dir = target.global_position
		else:
			debug_path_custom_color = Color.RED
		
		target_position = _target_dir
	
	if searching:
		if is_navigation_finished():
			search_points.pop_front()
		
		if search_points.is_empty():
				searching = false
				stop_navigating.emit()
				return
		
		target_position = search_points[0]
	
	if is_navigation_finished():
		stop_navigating.emit()
		return
	
	var direction := (get_next_path_position() - global_position).normalized()
	navigate.emit(direction)
	velocity = parent_velocity
