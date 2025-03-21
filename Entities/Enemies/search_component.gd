class_name SearchComponent extends Node

signal start_search(search_points: Array[Vector3])

@export_range(1, 20) var max_search_point: int
@export var wait_time_befor_search: float

var last_enemy: CharacterBody3D = null

var waiting := false

func _on_enemy_detected(enemy: CharacterBody3D) -> void:
	waiting = false
	last_enemy = enemy

func _on_enemy_lost() -> void:
	waiting = true
	await get_tree().create_timer(wait_time_befor_search, true, true).timeout
	if !waiting:
		return
	waiting = false
	var points := _search()
	last_enemy = null
	start_search.emit(points)

func _search() -> Array[Vector3]:
	var enemy_rid := last_enemy.get_rid()
	
	var points_array: Array[Vector3]
	
	if Global.findable_entities_regions_rids[enemy_rid]:
		var enemy_region_rid := Global.findable_entities_regions_rids[enemy_rid]
		
		for _i in range(max_search_point):
			points_array.append(NavigationServer3D.region_get_random_point(enemy_region_rid, 1, true))
	
	return points_array
