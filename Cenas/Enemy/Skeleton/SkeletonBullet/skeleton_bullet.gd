extends Bullet

func _ready() -> void:
	super._ready()
	area.collision_layer = Globals.layers["enemy"]
	area.collision_mask = Globals.layers["player"]
	
func _on_area_2d_body_player_entered(body: Node2D) -> void:
	var player = body.get_parent() as Player
	if !player: return
	
	player.take_knockback(dir, 10)
	player.take_damage(1)
