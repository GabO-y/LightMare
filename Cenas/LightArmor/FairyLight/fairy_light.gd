extends LightArmor

class_name FairyLight

@export var aim_sprite: Sprite2D

var can_shot = true
var bullets_moving: Array[Dictionary]
var last_dir: Vector2
var time_to_shoting = 0
var can_shot_timer = 0
var bullets = 50

func _ready() -> void:
	super._ready()
	set_price(50)

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_toggle_armor"):
		toggle_activate()

func _physics_process(delta: float) -> void:
	
	var x_axis = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var y_axis = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	
	var dir = Vector2(x_axis, y_axis)
	
	if dir.length() < 0.2:
		dir = last_dir
	elif mouse_move:
		var mouse_pos = get_global_mouse_position()
		dir = (mouse_pos - global_position).normalized()
	else:
		last_dir = dir
		
	aim_sprite.rotation = dir.angle()
	
	shot_logic(delta, dir)
	
func toggle_activate():
	super.toggle_activate()	
	aim_sprite.visible = is_active
	
	
func shot(angle):
	
	var bullet = load("res://Cenas/LightArmor/Bullet/Bullet.tscn").instantiate() as Bullet
	
	print(bullet)
	
	Globals.room_manager.call_deferred("add_child", bullet)
	
	bullet.global_position = global_position
	
	bullet.shot_dir = Vector2.from_angle(angle)
	bullet.is_shot = true
	
	can_shot = false
	bullets -= 1
	
func shot_logic(delta, dir):
	
	if bullets <= 0:
		return
	
	if (
		Input.is_action_just_pressed("ui_shot")
		and 
		is_active and can_shot
	):
		shot(dir.angle())
		
	if not can_shot:
		can_shot_timer += delta
		if can_shot_timer >= time_to_shoting:
			can_shot = true
			can_shot_timer = 0
	
