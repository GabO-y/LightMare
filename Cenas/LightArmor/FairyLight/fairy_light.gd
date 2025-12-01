extends LightArmor

class_name FairyLight

var timer: float = 0.0
var duration: float = 1.5
var can_shot: bool = true

func _ready() -> void:

	super._ready()
	
	set_price(50)
	
	set_max(20, "damage", "value")
	set_min(5, "damage", "value")
	
	set_max(Vector2(1.3, 1.3), "distance", "value")
	set_min(Vector2(0.7, 0.7), "distance", "value")
	
	set_max(1.0, "time_attack", "value")
	set_min(3.0, "time_attack", "value")
	
	set_min(10.0, "distance", "price")
	set_max(100.0, "distance", "price")
	
	set_max(50.0, "damage", "price")
	set_min(2, "damage", "price")
	
	set_max(50.0, "time_attack", "price")
	set_min(10, "time_attack", "price")
	
	set_max(3, "time_attack", "level")
	
	_update()

func _process(delta: float) -> void:

	if Globals.player.is_in_menu: return	
	
	damager_ene(delta)
	
	if Input.is_action_just_pressed("shoot_bullet"):
		try_shoot()
		
	if Input.is_action_just_pressed("ui_toggle_armor"):
		toggle_activate()
		
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
		rotation = dir.angle()
	elif mouse_move:
		var mouse_pos = get_global_mouse_position()
		dir = (mouse_pos - global_position).normalized()
		rotation = dir.angle() 
	
	if dir == Vector2.ZERO or dir.length() <= 0.2:
		dir = last_armor_dir
	
	last_armor_dir = dir
	armor_dir = dir

func try_shoot():
	
	if not can_shot or not is_active: return
	can_shot = false
	
	var b = load("res://Assets/LightArmor/FairyLight/FLBullet.tscn").instantiate() as Bullet
	Globals.room_manager.current_room.add_child(b)
	
	b.dir = armor_dir
	b.global_position = global_position
	b.armor = self
	b.start()
	
	b.scale = distance
	
func _update():
	super._update()
