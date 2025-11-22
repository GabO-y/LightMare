extends Item

class_name Key

@export var particles_node: CPUParticles2D

var door1: Door
var door2: Door

var is_going_to_door: bool = false

var is_key_moment: bool = false
var is_await_moment: bool = false

var finish_key_moment: bool = false
var finish_await_moment: bool = false

var key_manager: KeyManager

func _ready() -> void:
	super._ready()
	
func _process(delta: float) -> void:
	
	if Input.is_anything_pressed():
		if is_key_moment:
			finish_get_key()		
		elif is_await_moment:
			finish_await()
			
	super._process(delta)

func start_chase_player():
	super.start_chase_player()
	curve.set_t(0.007)
	
# Fazer a parte de quando a sala nao finalizadas pra que ele crie uma chave
	
func use():
	key_manager.key = null
	door1.open()
	queue_free()
	
func finish_get_key():
	
	if finish_key_moment: return
	finish_key_moment = true
	
	set_go_to(door1.position)
	use_when_arrieve.connect(_open_door_and_wait)

func start_particles():
	
	var tween = create_tween()
	particles_node.visible = true

	tween.tween_property(particles_node, "amount", 100, 0.001)
	tween.tween_property($Sprite2D, "modulate:a", 0.0, 2.0)
	
	is_key_moment = false
		
	await tween.finished
	is_await_moment = true
	
	
func finish_await():
	
	if finish_await_moment: return
	finish_await_moment = true
	
	is_await_moment = false
	
	Globals.player.is_getting_key = false
	set_process(false)
	
	Globals.player.set_process(true)
	Globals.player.set_physics_process(true)
	
	Globals.house.desable_camera()
	use()		
	
	finish_key_moment = false
	finish_await_moment = false
	
func _open_door_and_wait():
	
	visible = false
	
	door1.open()
	
	is_await_moment = true
	is_key_moment =  false

signal use_when_arrieve
	
