class_name FindableComponent extends Node3D

var map_sync: bool = false

func _ready() -> void:
	_setup.call_deferred()

func _physics_process(_delta: float) -> void:
	if map_sync:
		_get_nav_map()

func _setup() -> void:
	await NavigationServer3D.map_changed
	map_sync = true

func _random_point(nav_region_rid: RID) -> Vector3:
	return NavigationServer3D.region_get_random_point(nav_region_rid, 1, false)

func _get_nav_map() -> void:
	var nav_map_rid: RID = get_world_3d().navigation_map
	var closest_nav_region_rid := NavigationServer3D.map_get_closest_point_owner(nav_map_rid, global_position)
	Global.findable_entities_regions_rids = {
		get_parent().get_rid(): closest_nav_region_rid
	}
