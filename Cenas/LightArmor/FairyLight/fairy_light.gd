extends LightArmor

class_name FairyLight

var timer: float = 0.0
var duration: float = 1.5
var can_shot: bool = true

func _process(delta: float) -> void:
	
	super._process(delta)
	
	if Input.is_action_just_pressed("shoot_bullet"):
		try_shoot()
		
	if not can_shot:
		timer += delta
		if timer >= duration:
			can_shot = true
			timer = 0.0
		
	
func _physics_process(delta: float) -> void:
	
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
	
func try_shoot():
	
	if not can_shot: return
	can_shot = false
	
	var b = load("res://Cenas/LightArmor/FairyLight/BulletFairyLight/FLBullet.tscn").instantiate() as Bullet
	Globals.room_manager.current_room.add_child(b)
	
	b.dir = armor_dir
	b.start()
