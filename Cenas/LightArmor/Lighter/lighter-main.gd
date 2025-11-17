extends LightArmor

func _ready() -> void:
	super._ready()
	set_price(20)
	set_min(1.0, "time_attack")
	update()
	
func _process(delta: float) -> void:
	super._process(delta)
	
