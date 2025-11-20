extends LightArmor

func _ready() -> void:
	super._ready()
	
	set_price(20)
	
	set_max(3, "damage", "value")
	set_min(1, "damage", "value")
	
	set_max(Vector2(2.0, 2.0), "distance", "value")
	set_min(Vector2(1.0, 1.0), "distance", "value")
	
	set_max(0.1, "time_attack", "value")
	set_min(1.0, "time_attack", "value")
	
	set_max(2, "time_attack", "level")
	
	set_min(10.0, "distance", "price")
	set_max(150.0, "distance", "price")
	
	set_max(70, "damage", "price")
	set_min(2, "damage", "price")
	
	set_max(100, "time_attack", "price")
	set_min(10, "time_attack", "price")
	
func _process(delta: float) -> void:
	super._process(delta)
	
