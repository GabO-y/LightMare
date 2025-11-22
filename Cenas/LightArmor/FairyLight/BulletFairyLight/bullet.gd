extends Bullet

class_name FLBullet

@export var icon: Sprite2D

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	icon.rotate(0.1)
