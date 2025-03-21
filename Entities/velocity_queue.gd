class_name VelocityQueue extends Node

@export var velocity_parent: CharacterBody3D
@export var timer: Timer
@export var timer_wait_time: float = 2.0
@export var max_queue_size: int
@export var max_age_ms: float = 1000.0

var queue: Array[Dictionary]
var avg: Vector3

func _ready() -> void:
	timer.wait_time = timer_wait_time
	timer.start()
	timer.timeout.connect(func():
		if velocity_parent:
			add_velocity()
	)

func clear_queue() -> void:
	queue.resize(0)

func get_avg() -> Vector3:
	if queue.is_empty():
		return Vector3.ZERO
	
	if ceil(queue.size() * 2) < floor(max_queue_size / 2):
		return Vector3.ZERO
	
	var sum := Vector3.ZERO
	for sample in queue:
		if sample:
			sum += sample["velocity"]
	
	return sum / queue.size()

func _remove_expired() -> void:
	var current_time := Time.get_ticks_msec()
	
	var i := 0
	while i < queue.size():
		var sample := queue[i]
		if sample:
			if current_time - sample["time"] > max_age_ms:
				queue.remove_at(i)
			else:
				i += 1

func add_velocity() -> void:
	if velocity_parent == null:
		clear_queue()
		return
	
	if queue.size() > max_queue_size:
		queue.pop_front()
	
	var element := {
		"velocity": velocity_parent.velocity,
		"time": Time.get_ticks_msec()
	}
	
	queue.push_back(element)
	_remove_expired()
