extends Item

class_name Coin

@export var anim: AnimatedSprite2D

func _ready() -> void:
	
	super._ready()
	
	type = get_type()
	anim.play(str(type))
	is_move = true
	

func get_value() -> int:
	
	var value: int = 0
	
	match type:
		1: value = 1
		2: value = 5
		3: value = 10
		4: value = 20
		
	return value
	
func get_type():
	var p = randf()
	var thresholds = [0.9, 0.8, 0.7, 0.0]
	var types = [4, 3, 2, 1]
	var type = 1  # padrão

	for i in range(thresholds.size()):
		if p >= thresholds[i]:
			type = types[i]
			break
			
	return type
	


		
	
	
