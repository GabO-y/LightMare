extends Menu

class_name DieMenu

@export var house: House
@export var anim: AnimationPlayer

var can_skip_1: bool = false
var can_skip_2: bool = false
var can_skip_3: bool = false

var can_reset: bool = false

@export var a_coins: Label
@export var c_coins: Label
@export var ene_count: Label

var timer: float = 0.0
var duration: float = 0.0
var is_awaiting: bool = false

var original_c_coin_pos: Vector2

var final_results: Dictionary

func _ready() -> void:
	reset()
	
func reset():
	set_visi(false)
	set_process_input(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
	
	original_c_coin_pos = c_coins.global_position
	
func _process(delta: float) -> void:
	
	if Input.is_anything_pressed():
		if can_skip_1:
			can_skip_1 = false
			skip_1()
		elif can_skip_3:
			can_skip_3 = false
			skip_3()
		elif can_reset:
			can_reset = false
			house.reset()
			c_coins.global_position = original_c_coin_pos
	
	if is_awaiting:
		if timer >= duration:
			is_awaiting = false
			timer = 0.0
			match final_results["part"]:
				
				1:
					can_skip_1 = true
					
					set_process_input(true)
					set_process_unhandled_input(true)
					set_process_unhandled_key_input(true)
				2:
					can_skip_3 = true
				"reset":
					can_reset = true
		else:
			timer += delta
	
#func _input(event: InputEvent) -> void:
	#
	#if event is InputEventMouse:
		#if event.button_mask == 0:
			#return
	#
	#if can_skip_1:
		#can_skip_1 = false
		#skip_1()
	#elif can_skip_3:
		#can_skip_3 = false
		#skip_3()
	#elif can_reset:
		#pass

func skip_1():
	
	final_results["tween"].stop()
	
	Globals.player.scale = final_results["player_scala"]
	Globals.player.body.global_position = final_results["player_pos"]
	
	anim.seek(anim.current_animation_length + 1000, true)
	Globals.player.anim.set_frame_and_progress(1000, 1000)
	
	start_anim_2()
			
func skip_3():
	
	can_skip_3 = false
		
	final_results["tween"].stop()
	
	ene_count.text = str(Globals.enemies_defalted)
	
	anim.seek(anim.current_animation.length() + 1000, true)
	anim.play("3")
		
	anim.seek(anim.current_animation.length() + 1000, true)

	a_coins.text = str(Globals.player.coins)
	
	final_results["part"] = "reset"
	duration = 0.5
	is_awaiting = true
				
func start_anim_1():
	
	Globals.house.menu_manager.is_in_menu = true
	
	anim.play("1")
	final_results["part"] = 1

	part_1_tweens()
	
	final_results["tween"].finished.connect(start_anim_2)
	
	timer = 0.0
	duration = 0.5
	is_awaiting = true
		
func start_anim_2():
		
	final_results["part"] = 2

	anim.play("2")
	
	set_visi(true, 2)
	
	a_coins.text = str(Globals.player.coins - Globals.conquited_coins, " + ")
	
	part_2_tweens()
	
	final_results["tween"].finished.connect(start_anim_3)
	
	duration = 0.5
	is_awaiting = true	
	
func start_anim_3():
	
	final_results["type"] = 3
	c_coins.text = str(Globals.conquited_coins)
	
	part_3_tweens()
	
	final_results["tween"].finished.connect(
		func():
			
			can_skip_3 = false
			
			c_coins.visible = false
			a_coins.text = str(Globals.player.coins)
			
			final_results["part"] = "reset"
			duration = 0.5
			is_awaiting = true	
	)
	
func part_3_tweens():
	
	var tween = create_tween()
	final_results["tween"] = tween

	tween.tween_method(move_c_coin, 0.0, 1.0, 0.3)
	
func move_c_coin(t: float):
	c_coins.global_position = c_coins.global_position.move_toward(a_coins.global_position, t * 10)
	if c_coins.global_position.distance_to(a_coins.global_position) < 5:
		c_coins.visible = false
	
func part_2_tweens():
	
	var tween = create_tween()
	tween.set_parallel()
	
	final_results["tween"] = tween
	
	var duration: float = 5.0
	
	tween.tween_method(update_coins_label, 0.0, 1.0, duration)
	tween.tween_method(update_ene_defalted, 0.0, 1.0, duration)

func update_coins_label(t: float):
	c_coins.text = str(int(Globals.conquited_coins * t))

func update_ene_defalted(t: float):
	ene_count.text = str(int(Globals.enemies_defalted * t))
	
func part_1_tweens():
	
	set_visi(true, 1)
	
	var tween = create_tween()
	tween.set_parallel()
	
	final_results["player_pos"] = house.room_manager.current_room.camera.global_position + Vector2(0, -30)
	
	final_results["player_scala"] = Vector2(2.5, 2.5)
	final_results["tween"] = tween
	
	var durarion: float = 5.0
	
	tween.tween_property(Globals.player.body, "global_position", final_results["player_pos"], durarion)
	tween.tween_property(Globals.player, "scale", final_results["player_scala"], durarion)
	
	Globals.player.anim.play("die")
	
func set_visi(mode: bool, type: int = 0):	
	for child in anim.get_children():
		if child.name.contains(str(type)) or type == 0:
			for c in child.get_children():
				c.visible = mode
						
