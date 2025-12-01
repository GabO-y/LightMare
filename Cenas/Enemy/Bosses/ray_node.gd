extends Node2D

class_name RayNode

var infos: Array[Dictionary]

@export var up: RayCast2D
@export var down: RayCast2D
@export var left: RayCast2D
@export var right: RayCast2D

var rays: Array[Dictionary]
var dir: Vector2

var last_coll: RayCast2D
var finish_collision: bool = true

var change_dir_coldown: float = 1.0
var change_dir_timer: float = 0.0
var can_change_dir: bool = true

var dirs = {
		Vector2( 1,   1)  : {"right" : Vector2(-1,  1), "down" : Vector2( 1, -1)},
		Vector2( 1,  -1)  : {"right" : Vector2(-1, -1), "up"   : Vector2( 1,  1)},
		Vector2(-1,   1)  : {"left"  : Vector2( 1,  1), "down" : Vector2(-1, -1)},
		Vector2(-1,  -1)  : {"left"  : Vector2( 1, -1), "up"   : Vector2(-1,  1)}
	}

func _ready() -> void:
	rays.append_array(
		[
			{
				"name": "up",
				"ray": up
			},
			{
				"name": "down",
				"ray": down
			},
			{
				"name": "left",
				"ray": left
			},
			{
				"name": "right",
				"ray": right
			},
		]
	)
	
	for key in rays:
		var ray = key["ray"] as RayCast2D
		ray.collision_mask = Globals.layers["current_wall"]

func _process(delta: float) -> void:
	if not can_change_dir:
		change_dir_timer += delta
		if change_dir_timer >= change_dir_coldown:
			change_dir_timer = 0.0
			can_change_dir = true
		

func is_colliding() -> bool:
	for key in rays:
		var ray = key["ray"]
		if ray.is_colliding():
			dir = get_new_dir(dir, key["name"])
			if finish_collision:
				last_coll = ray
				finish_collision = false
			else:
				if not last_coll.is_colliding():
					finish_collision = true
			return true
	return false
	
func get_new_dir(dir: Vector2, name: String):

	if dirs.has(dir):
		if dirs[dir].has(name):
			return dirs[dir][name]
			
	return dir

func get_random_diagonal_dir():
	var type = randi_range(1, 4)
	var dir: Vector2
	match type:
		1: dir = Vector2(1, 1)
		2: dir = Vector2(1, -1)
		3: dir = Vector2(-1, 1)
		4: dir = Vector2(-1, -1)
	return dir

func set_active(mode: bool):
	for ray in rays:
		if mode:
			ray["ray"].collision_mask = Globals.layers["current_wall"]
			ray["ray"].collide_with_areas = Globals.layers["current_wall"]
		else:
			ray["ray"].collision_mask = 0
