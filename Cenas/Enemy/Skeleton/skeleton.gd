extends Enemy

class_name Skeleton

@export var ray: RayCast2D
@export var ray_marker: Marker2D

enum State {PREPARE_ATTACK, DASHING, AWAITING}

var attack_coldown: float = 3.0

var duration: float = 0.0
var timer: float = 0.0

var dash_speed: float = 80.0
var target_pos_dash: Vector2

# como o esqueleto so para quando nao estiver colidiondo em ngm,
# conforme ele colide, o tempo do dash tbm diminui
var count_collision: int = 0

var current_state: State 

# prepere -> await -> dash

func _ready() -> void:
	current_state = State.PREPARE_ATTACK
	setup_prepere_attack()
	speed.set_min(80, "value")

func _process(delta: float) -> void:
	animation_logic()

func _physics_process(delta: float) -> void:
	match current_state:
		State.DASHING:
			dash_move(delta)
		State.PREPARE_ATTACK:
			prepere_attack_logic(delta)
		State.AWAITING:
			await_move(delta)
			
	super._process(delta)
	
func dash_move(delta: float):
	
	var collison = body.move_and_collide((dir * speed.get_value()).normalized())
	
	if collison:
		count_collision += 1
		setup_new_direction_point()
		setup_dash()
		duration -= count_collision * 0.1

	if timer >= duration:
		current_state = State.PREPARE_ATTACK
		setup_prepere_attack()
		dir = dir_to_player()
		return
		
	timer += delta
	var test = dir * speed.get_value()
	
	print("TEST: ", test)
	
	body.velocity = test
	body.move_and_slide()
	
func animation_logic():
	
	var play = str(
		("walk" if current_state == State.DASHING else "idle"),
		("_back" if dir.y < 0 else "")
		)
		
	anim.flip_h = dir.x > 0
	anim.play(play)
	
	
func prepere_attack_logic(delta: float):
		
	if timer >= duration:
		attack()
		
		setup_await()
		return
		
	timer += delta
	
func attack():
	
	var b = load("res://Cenas/Enemy/Skeleton/SkeletonBullet/SkeletonBullet.tscn").instantiate() as Bullet
	
	Globals.room_manager.current_room.add_child(b)
	
	b.global_position = body.global_position
	
	b.dir = dir_to_player()
	b.rotation = b.dir.angle()
	b.start()
	
func await_move(delta):
	if timer >= duration:
		count_collision = 0
		setup_new_direction_point()
		setup_dash()
		return
	timer += delta
	
func setup_new_direction_point():
	
	var possibles_points = rotate_and_get_possibles_points()
	var p: Vector2
	
	if not possibles_points.is_empty():
		p = possibles_points.pick_random()
	else:
		p = dir_to_player()
	
	target_pos_dash = p
	dir = body.global_position.direction_to(target_pos_dash)

func rotate_and_get_possibles_points() -> Array[Vector2]:
		
	var rotates: int = 100
	var avaliable_pos: Array[Vector2] = []
	
	for i in range(rotates):
		
		if not ray.is_colliding():
			avaliable_pos.append(ray_marker.global_position)
						
		ray.rotation += (2 * PI) / rotates
	
	return avaliable_pos
		
func setup_dash():
	duration = 0.5
	timer = 0.0
	current_state = State.DASHING

	
func setup_prepere_attack():
	duration = 3.0
	timer = 0.0
	current_state = State.PREPARE_ATTACK
	
func setup_await():
	duration = 1.0
	timer = 0.0
	current_state = State.AWAITING
		
func rotate_ray(t: float):
	ray.rotate(t)
	
	if ray.is_colliding():
		return null
		
	return ray.target_position
	
	
