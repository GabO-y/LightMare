extends Room

class_name BossRoom

@export var boss: Boss

func _ready() -> void:
	
	boss.room = self
	
	super._ready()

func desable():
		
	if finish:
		for door in doors:
			door.all_lock()
	
	if is_instance_valid(boss):
		boss.desable()

	super.desable()
	
func enable():
	boss.enable()
	super.enable()
	
func switch_process(mode: bool):	
	super.switch_process(mode)
	if is_instance_valid(boss):
		boss.set_active(mode)
		
func reset():
	super.reset()
	boss.reset()
