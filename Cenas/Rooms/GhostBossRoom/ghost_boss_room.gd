extends BossRoom

class_name GhostBossRoom

@export var segs_to_ghost_room: Node2D

func _ready() -> void:
	super._ready()
	boss.room = self
	
func reset():
	super.reset()
	
	boss.queue_free()
	boss = load("res://Cenas/Enemy/Bosses/GhostBoss.tscn").instantiate() as GhostBoss
	add_child(boss)
	
	boss.room = self
	
	boss.reset()
	
	boss.global_position = spot_boss_spawn.global_position
	
