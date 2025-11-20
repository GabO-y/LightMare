extends Boss
class_name GhostBoss

enum State {CHASING, SPECIAL, STOPED, PREPERE_ATTACK, DYING}
enum Specials {GHOSTS_RUN, CRASH_WALL}

var current_state: State
var current_special: Specials

var is_on_special: bool = false

var is_laugh_animation: bool = false

# Variaveis que devem vir do quarto que ele está
#######################
#@export var area_to_ghost_run: Area2D
# vai conter os seguimentos para o spawn num ponto aleatorio
@export var segs_to_ghost_run: Node2D
@export var screen_notifier: VisibleOnScreenNotifier2D
#######################

@export var slash_node: Node2D
@export var slash_node_timer: Timer

@export var area_attack_ghosts_run: Area2D
@export var ghost_spawn_node: Node2D

var is_prepere_attack: bool = false
var prepere_attack_duration: float = 0.0
var prepere_attack_timer: float = 0.0
# conforme a logica de ataque, dependendo, o tempo que ele precisa
# esperar muda, essa são para padronizar
var prepere_attack_duration_when_await: float = 1.0
var prepere_attack_duration_normal: float = 0.5
var is_player_area_attack: bool = false

# quando player entra na area, o boss entra em modo de ataque, 
# caso a varivel seja true, msm que o player saia da area, ele ainda 
# vai esperar dar o ataque
var wait_attack_finish: bool = true

var is_toward_ghost_run: bool = false
# a medida que os fantasmas são gerados, eles ficam
# parados por um tempo, essa varivel que controlará isso
var time_await_ghost_run: float = 0.1 # 1
var is_entrece: bool = false
var quant_ghost_create:int = 10
var ghost_count:int = 0
var min_dist_ghost_run: int = 90

var timer_special = 0.0
@export var special_coldown: float = 10.0

var stop_timer: float = 0.0
var stop_duration: float = 2.0

var is_dying: bool = false

var count_drops: int = 0
var total_drops: int = 50
var timer_to_drop: float = 0.0
var coldown_to_drop: float = 0.1

var is_flicking: bool = false

func _ready() -> void:
		
	z_index = 2
	
	set_process(false)
	set_physics_process(false)

	#screen_notifier.screen_exited.connect(_ghost_out)
	
	super._ready()
	
func _process(delta: float) -> void:
	_animation_logic()

func _physics_process(delta: float) -> void:
	
	print("heath: ", heath)
	print("life_bar: ", life_bar.value)
	
	if not is_active: return
	
	if is_dying:
		current_state = State.DYING
		
	match current_state:
		State.CHASING:
			chase_move()
		State.PREPERE_ATTACK: 
			if is_prepere_attack:
				prepere_attack_logic(delta)
				return
			if dist_to_player() > 40 and not is_laugh_animation:
				current_state = State.CHASING
		State.SPECIAL:
			
			special_move()
			
		State.STOPED:
			pass
		State.DYING:
			
			if is_stop: 
				timer_to_drop = 0.0
				return
			
			if timer_to_drop >= coldown_to_drop:
				Globals.item_manager.drop_by_name("coin", body.global_position)
				count_drops += 1
				timer_to_drop = 0.0
				
			timer_to_drop += delta
				
			if count_drops >= total_drops:
				finish_die()
			
			return
			
	timer_special += delta
		
	if timer_special >= special_coldown and not is_on_special:
		start_special()
		
func special_move():	
	match current_special:
		Specials.GHOSTS_RUN:
			ghost_run_move()
		Specials.CRASH_WALL:
			pass

### Ghosts Run ###

func setup_ghost_run():
	
	body.collision_mask = 0
	
	area_attack_ghosts_run.collision_layer = Globals.layers["boss"]
	area_attack_ghosts_run.collision_mask = Globals.layers["player"]
	
	#area_to_ghost_run.collision_mask = Globals.layers["boss"]
	
	speed = 150
	
func ghost_run_move():
				
	if is_entrece:
		entrace()
		return
		
	if is_toward_ghost_run:
		body.velocity = last_dir * speed
		body.move_and_slide()
		return
	
	if dist_to_player() < min_dist_ghost_run:
		is_toward_ghost_run = true
		
	chase_move()
	last_dir = dir
	
func set_ghost_to_1(ghost: Ghost):
	ghost.type_special = 1
	time_await_ghost_run += 0.5
	await Globals.time(time_await_ghost_run)
	
	if is_instance_valid(ghost):
		ghost.is_stop = false
	
func set_ghost_to_2(ghost: Ghost):	
	ghost.type_special = 2		
	time_await_ghost_run += 0.01
	
	await Globals.time(time_await_ghost_run)
	
	if is_instance_valid(ghost):
		ghost.is_stop = false

func create_ghosts(pos: Vector2):
	
	var ghost: Ghost = load("res://Cenas/Enemy/Ghost/Ghost.tscn").instantiate()
	
	ghost.is_stop = true
	ghost.current_state = Ghost.State.SPECIAL
	
	ghost_spawn_node.add_child(ghost)

	ghost.global_position = pos 
	ghost.speed = 300

	
	ghost.screen_notifier.screen_exited.connect(
				func():
					_ghost_out(ghost)
	)

	return ghost
	
func get_random_point_in_line(line: Line2D) -> Vector2:
	
	var x1 = line.points[0].x
	var y1 = line.points[0].y
	var x2 = line.points[1].x
	var y2 = line.points[1].y
	
	var x = x1 + randf() * (x2 - x1)
	var y = y1 + randf() * (y2 - y1)
	
	# quando você tem um nó em uma posição, por exemplo (0, 0), essa posição 
	# é relativa ao nó pai, tipo, se o nó pai está em (5, 5) 
	# então a posição global/original do filho será (5, 5) + (0, 0) = (5, 5)

	# se você mover o filho para (2, 2), sua posição global passa 
	# a ser (5, 5) + (2, 2) = (7, 7), o valor local da posição 
	# é relativo, e ao somar com a posição do pai você obtém a original
	# daquele nó
	
	# por isso subitraio a posição global, já que ele começa, pois preciso da
	# posição original no mundo, pois os fantamas que nascem dele, precisam do
	# no mundo e não relativo a seu pai
	
	return Vector2(x, y)

func create_ghosts_and_run():
		
	var ghosts_array: Array[Ghost]
	
	var type = [1, 2].pick_random()
	
	if type == 2:
		quant_ghost_create = 15
		time_await_ghost_run += 1
	
	for i in range(quant_ghost_create):

		var line = get_random_line()
		var gho = create_ghosts(get_random_point_in_line(line)) as Ghost
		
		gho.speed_att.set_min(150, "value")
		gho.setup()
		
		gho.dir = {
			"Up": Vector2(0, 1), "Down": Vector2(0, -1),
			"Left": Vector2(1, 0), "Right": Vector2(-1, 0)
		}[line.name]
		
		ghosts_array.append(
			gho
		)
		
		if i == quant_ghost_create - 1:
			gho.enemy_die.connect(
				func(ene):
					finish_ghosts_run()
			)
		
	var set_behavior_func: Callable = get_behavior_func(type)
	
	for gho in ghosts_array:
		if is_instance_valid(gho):
			set_ghost_generic(set_behavior_func, gho)
	
func get_behavior_func(type: int):
	match type:
		1: return set_ghost_to_1
		2: return set_ghost_to_2
	
	return set_ghost_to_1
		
func set_ghost_generic(set_gho: Callable, gho):
	set_gho.bind(gho).call()
		
func finish_ghosts_run():
	# com a chance dele nascer em baixo, ele fica perto o suficiente para
	# colidir com a area que faz o ghosts nascerem, o setup torna true denovo
	#area_to_ghost_run.monitoring = false
	
	body.global_position = get_random_point_in_line(get_random_line())
	is_entrece = true
	
		
func get_random_line() -> Line2D:	
	return segs_to_ghost_run.get_children().pick_random() as Line2D
	
func entrace():
	
	chase_move()
	
	if dist_to_player() < min_dist_ghost_run - 40 :
		prepare_attack()
		prepere_attack_timer = 0
		prepere_attack_duration = 0.3
		await Globals.time(0.6)
		setup()
	
###################
	
func _animation_logic():
	
	if is_laugh_animation or is_dying: return
	
	var play: String = "walk"
	
	if dir == Vector2.ZERO:
		dir = last_dir
	else:
		last_dir = dir
	
	if dir.y < 0:
		play += "_back"
	
	anim.flip_h = dir.x < 0
	anim.play(play)

func setup():
			
	set_process(true)
	set_physics_process(true)
	
	is_active = true
	body.collision_layer = Globals.layers["boss"]
	body.collision_mask = Globals.layers["player"] | Globals.layers["armor"]
	current_state = State.CHASING
	slash_node.visible = false
	timer_special = 0.0
	time_await_ghost_run = 1.0
	is_on_special = false
	ghost_count = 0
	quant_ghost_create = 10
	is_entrece = false
	#area_to_ghost_run.monitoring = true
	speed = 80
	is_toward_ghost_run = false
	damage_bar.visible = true

func reset():
	segs_to_ghost_run = room.segs_to_ghost_room
	
func chase_move():
		
	speed += 0.1
		
	if is_player_area_attack and dist_to_player() <= 40 and not is_on_special:
		prepare_attack()
		return
		
	dir = dir_to_player()	
	body.velocity = dir * speed
	body.move_and_slide()

func prepare_attack():
	current_state = State.PREPERE_ATTACK
	is_prepere_attack = true
	prepere_attack_timer = 0
	wait_attack_finish = true

func prepere_attack_logic(delta: float):
	# logica basica, para ficar parado um tempinho,
	# dps atacar
	prepere_attack_timer += delta
	
	if prepere_attack_timer >= prepere_attack_duration:	
		# se o player permanecer na area de ataque, msm
		# dps dele já ter atacado, ele não desativa a varievel,
		# apenas aumenta a duração pro proximo ataque
		
		if is_player_area_attack:
			prepare_attack()
			prepere_attack_duration = prepere_attack_duration_when_await
			wait_attack_finish = false
		else: 
			is_prepere_attack = false
			prepere_attack_duration = prepere_attack_duration_normal
			
		slash(dir_to_player())

func slash(dir: Vector2):
	
	
	slash_node.visible = true
	var angle = dir.angle() - PI/4
	slash_node.rotation = angle
	slash_node_timer.start()
	speed = 80
	
	if is_player_area_attack:
		Globals.player.take_knockback(dir, 20)
		Globals.player.take_damage(damage)

### Special generico ###

func start_special():
	
	if is_on_special: return
	
	anim.play("laugh")
	
	current_state = State.STOPED
	is_laugh_animation = true
	is_on_special = true

	await anim.animation_finished
	
	is_laugh_animation = false
	current_state = State.SPECIAL
	
	current_special = get_random_special()
		
	match current_special:
		Specials.GHOSTS_RUN:
			setup_ghost_run()
		Specials.CRASH_WALL:
			pass
			
func get_random_special() -> Specials:
	# Logica para ir um ataque por vez
	return Specials.GHOSTS_RUN

########################

func _on_timer_to_hide_view_timeout() -> void:
	slash_node.visible = false
	
func _on_slash_player_body_entered(body: Node2D) -> void:
	var player = body.get_parent() as Player
	if !player: return
	is_player_area_attack = true

func _on_slash_area_player_body_exited(body: Node2D) -> void:

	var player = body.get_parent() as Player
	if !player: return
	
	is_player_area_attack = false

	if is_on_special: return

	if not wait_attack_finish:
		current_state = State.CHASING
		

# quando o fantasma esta correndo, se ele atravessar vc, vc toma dano
func _on_area_attack_to_ghosts_run_player_body_entered(body: Node2D) -> void:	
	var player = body.get_parent() as Player
	if !player: return
	
	if is_dying or not is_active: return
	
	player.take_knockback(dir, 20)
	player.take_damage(damage)
	
func _ghost_out(me):
							
	if me is GhostBoss:
		create_ghosts_and_run()	
		
	if me is Ghost:
		me.die()
		
func die():
	is_dead = true
	is_dying = true
	start_die()
	
func start_die():
	
	current_state = State.DYING
	anim.play("partial_die")
	start_flicks()
	
	await anim.animation_finished
	
	anim.play("loop_partial_die")
	is_stop = false
	
func finish_die():
	
	anim.play("die")
	is_dead = true
	is_stop = true
		
	await anim.animation_finished
	
	is_stop = false
	Globals.room_manager.current_room.finish = true
	Globals.room_manager._clear_effects()
	queue_free()
	
func start_flicks():
	is_flicking = true
	color_to_white()
	
func color_to_white():
	
	if not is_flicking:
		color_to_normal()
		return
		
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.2)
	tween.finished.connect(color_to_normal)
	
func color_to_normal():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	
	if is_flicking:
		tween.finished.connect(color_to_white)
		
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	_ghost_out(self)
