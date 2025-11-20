extends Enemy
class_name Boss

# quarto que o boss se encontra
@export var room: GhostBossRoom
@export var life_bar: ProgressBar
@export var damage_bar: ProgressBar

func _ready() -> void:
	damage_bar.max_value = heath
	life_bar.max_value = heath
	damage_bar.value = heath
	life_bar.value = heath

func set_active(mode):
	
	if mode: setup()
	
	set_process(mode)
	set_physics_process(mode)
	
	is_stop = !mode
	is_active = mode
	visible = mode
	
	super.set_active(mode)

	
func enable():
	set_active(true)
	
func desable():
	set_active(false)

	
func setup():
	pass
	
func reset():
	pass
	
func take_damage(damage):
	super.take_damage(damage)
	is_damaged.emit()
	


signal is_damaged
