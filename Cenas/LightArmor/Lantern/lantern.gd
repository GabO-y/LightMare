extends LightArmor

class_name Lantern

@export var rotation_speed := 5.0

var ene_on_light = {}

func _ready() -> void:
	super._ready()
	
	set_max(10, "damage", "value")
	set_min(2, "damage", "value")
	
	set_max(Vector2(1.7, 2.0), "distance", "value")
	set_min(Vector2(1.2, 1.2), "distance", "value")
	
	set_max(0.5, "time_attack", "value")
	set_min(1.2, "time_attack", "value")
	
	set_min(10.0, "distance", "price")
	set_max(150.0, "distance", "price")
	
	set_max(70, "damage", "price")
	set_min(2, "damage", "price")
	
	set_max(100, "time_attack", "price")
	set_min(10, "time_attack", "price")
	
	set_max(3, "time_attack", "level")
	
func _process(delta):
		
	var x_axis = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var y_axis = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)

	var dir = Vector2(x_axis, y_axis)

	if dir.length() > 0.2: 
		rotation = dir.angle() - PI/2
	elif mouse_move:
		var mouse_pos = get_global_mouse_position()
		dir = (mouse_pos - global_position).normalized()
		rotation = dir.angle() - PI/2 
	
	armor_dir = dir
		
	super._process(delta)
	
