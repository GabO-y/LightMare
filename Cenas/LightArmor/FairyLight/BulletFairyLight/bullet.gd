extends Bullet

class_name FLBullet

@export var icon: Sprite2D
@export var light_area: Area2D

var armor: LightArmor

var is_wrapped: bool = false
var ene_wrapped: Enemy
var ene_in_light: Array[Dictionary]

func _ready() -> void:
	super._ready()
	set_process(false)
	
	area.collision_layer = Globals.layers["armor"]
	area.collision_mask = Globals.layers["enemy"] | Globals.layers["ghost"]
	
	light_area.collision_layer = Globals.layers["armor"]
	light_area.collision_mask =  Globals.layers["enemy"] | Globals.layers["ghost"]
	
func _physics_process(delta: float) -> void:	
	super._physics_process(delta)
	icon.rotate(0.1)
	
func _process(delta: float) -> void:

	if not is_wrapped or not ene_wrapped: return
	
	global_position = ene_wrapped.body.global_position
	damage_ene(delta)

func damage_ene(delta: float):
	
	for ene in ene_in_light:
		
		if not is_instance_valid(ene["ene"]): return
				
		if ene["time"] >= armor.time_to_damage:
			ene["ene"].take_damage(armor.damage)
			ene["time"] = 0.0
			
		ene["time"] += delta
		
func wrapped_ene(ene: Enemy):
	
	set_physics_process(false)
	set_process(true)
	
	ene_wrapped = ene
	is_wrapped = true
	light_area.monitoring = true
	
	ene_wrapped.enemy_die.connect(
		func(ene):
			queue_free()
			print("Acabou")
	)
	
func _on_light_area_ene_body_entered(body: Node2D) -> void:
	var ene = body.get_parent() as Enemy
	if not ene: return
	ene_in_light.append(
		{
			"ene": ene,
			"time": 0.0
		}
	)

func _on_light_area_ene_body_exited(body: Node2D) -> void:
	var ene = body.get_parent() as Enemy
	if not ene: return
	
	for ene_light in ene_in_light:
		if ene == ene_light["ene"]:
			ene_in_light.erase(ene_light)
			break
			
func _on_body_area_ene_body_entered(body: Node2D) -> void:
	
	if ene_wrapped: return
	
	var ene = body.get_parent() as Enemy
	if not ene: return
	
	wrapped_ene(ene)
