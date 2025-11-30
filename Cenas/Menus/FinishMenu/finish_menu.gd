extends Menu

class_name FinishMenu

@export var particles: Array[CPUParticles2D]
@export var anim: AnimationPlayer
@export var labels_node: Control
@export var labels: Array
@export var time_label: Label

var duration: float = 3.0
var timer: float = 0.0
var check_process: bool = false
var can_reset: bool = false

var min_sec = {}

func _ready() -> void:
	
	for label in labels_node.get_children():
		labels.append(label)
	
	set_active(false)
	set_process(false)
	
func _process(delta: float) -> void:
	
	if timer >= duration:
		can_reset = true
		timer = 0.0
		set_process(false)
		
	timer += delta


func _input(event: InputEvent) -> void:
	
	if not can_reset: return
	
	var reset: bool = false
	
	if event is InputEventMouse:
		if event.button_mask != 0:
			reset = true
	elif event is InputEventKey:
		reset = true
		
	if reset:
		Globals.house.reset()

func start():
	
	set_active(true)
	anim.play("1")
	
	Globals.player.set_active(false)
	start_tweens()
	
	var time = Globals.house.calc_game_time_sec()
	
	min_sec["min"] = time / 60
	min_sec["sec"] = time % 60

	await anim.animation_finished
	set_process(true)
	
func start_tweens():
	var tween = create_tween()
	
	var player = Globals.player
	
	tween.set_parallel()
	
	var center_pos = Globals.house.room_manager.current_room.camera.global_position
	
	tween.tween_property(player.body, "global_position", center_pos, 4.0)
	tween.tween_property(player, "scale", Vector2(3.0, 3.0), 4.0)
	tween.tween_method(random_time_effect, 0.0, 1.0, 10.0)
	
func random_time_effect(t):
	
	var r = randf() * 2 - 1  
	var f = pow(1 - t, 2) 
	
	var min = min_sec["min"] + (r * 100 * f)
	var sec = min_sec["sec"] + (r * 100 * f)
	
	time_label.text = str("%2d:%2d" % [min, sec])

func set_active(mode: bool, principal: bool = true):
	super.set_active(mode, principal)
	
	for cpu in particles:
		cpu.emitting = mode
	
	set_process(false)
	
	for label in labels:
		label.visible = mode
