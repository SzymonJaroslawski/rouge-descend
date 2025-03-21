class_name PredictionQueue extends RefCounted

var max_queue_size: int
var max_time_ms: float
var time_passed: float
var queue: Array[Dictionary]

func new_queue() -> void:
	queue.resize(max_queue_size)

func get_average() -> Vector3:
	if !queue or queue.size() == 0:
		return Vector3.ZERO
	
	var avg := Vector3.ZERO
	
	for element in queue:
		for elem in element:
			if elem is Vector3:
				avg += elem
	
	return avg / queue.size()

func clean() -> void:
	var indexes: PackedInt32Array
	indexes.resize(queue.size())
	var i := 0
	for element in queue:
		for elem in element.values():
			print(time_passed - elem, " ", max_time_ms)
			print(time_passed - elem >= max_time_ms)
			if time_passed - elem >= max_time_ms:
				indexes.append(i)
				i += 1
	
	print(indexes)
	print(queue.size())
	
	for index in indexes:
		queue.remove_at(index)
	
	if indexes.size() != 0:
		print("Cleaned")
		print(queue.size())

func add_to_queue(velocity: Vector3, time: float) -> void:
	clean()
	if queue.size() < max_queue_size:
		queue.pop_front()
	
	var element := {
		velocity: time
	}
	
	queue.push_back(element)
