extends Room

class_name BossRoom

@export var boss: Boss
@export var spot_boss_spawn: Marker2D

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
	
func set_active(mode: bool):	
	super.set_active(mode)
	if is_instance_valid(boss):
		boss.set_active(mode)
		
#func reset():
	#super.reset()
	#
	#print("BOSSSSSSS RESETADO")
	#boss.global_position = spot_boss_spawn.global_position - global_position
