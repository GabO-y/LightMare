extends LightArmor

class_name Lantern

@export var rotation_speed := 5.0

var ene_on_light = {}

func _ready() -> void:
	super._ready()
	set_max(5, "damage")
	set_max(70, "damage", true)

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
	
