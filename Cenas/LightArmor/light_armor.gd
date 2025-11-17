extends Node2D

class_name LightArmor

@export var damage: int = 0
@export var time_to_damage: float = 0.0
@export var distance: Vector2 = Vector2.ONE

@export var is_active = true
@export var area: Area2D

@export var can_active: bool = true

var infos: Dictionary = {
	"price": 0,
	"is_locked": true,
	"max": {
		"price": {
			"damage": 0,
			"distance": 0,
			"time_attack": 0
		},
		"damage": 0,
		"distance": 0,
		"time_attack": 0
	},
	"min": {
		"price": {
			"damage": 0,
			"distance": 0,
			"time_attack": 0
		},
		"damage": 0,
		"distance": 0,
		"time_attack": 0
	},
	"level":{
		"damage": 1,
		"distance": 1,
		"time_attack": 1
	}
}

var enemies_on_light: Dictionary[Enemy, float] = {}
var mouse_move = false

var armor_dir: Vector2 = Vector2.ZERO

func _ready() -> void:
	
	update()
	
	if !area: return
	
	area.collision_layer = Globals.layers["armor"] | Globals.layers["player"]
	area.collision_mask = Globals.layers["enemy"] | Globals.layers["boss"]
	
	area.body_entered.connect(_ene_on_light_area)
	area.body_exited.connect(_ene_exit_light_area)
	
func _process(delta: float) -> void:
	
	if Globals.player.is_in_menu: return
		
	damager_ene(delta)
	
	if Input.is_action_just_pressed("ui_toggle_armor"):
		toggle_activate()

func toggle_activate():
		
	if not can_active:
		if is_active:
			is_active = false
			visible = false
		return
	
	is_active = !is_active
	visible = is_active

	if not area: return
	
	var layer = Globals.layers["player"] | Globals.layers["armor"] | Globals.layers["current_wall"] if is_active else 0
	var mask = Globals.layers["ghost"] | Globals.layers["enemy"] | Globals.layers["boss"] if is_active else 0

	area.collision_layer = layer
	area.collision_mask = mask


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		mouse_move = true
	else:
		mouse_move = false
	
func damager_ene(delta: float):
	for ene in enemies_on_light.keys():
		if enemies_on_light[ene] >= time_to_damage:
			ene.take_damage(damage)
			enemies_on_light[ene] = 0.0
			continue
		enemies_on_light[ene] += delta
	
func _ene_on_light_area(ene_body):
	var ene = ene_body.get_parent() as Enemy
	if !ene: return
	enemies_on_light[ene] = 0.0
	
func _ene_exit_light_area(ene_body):
	
	var ene = ene_body.get_parent() as Enemy
	if !ene: return
	for key in enemies_on_light.keys():
		if ene == key:
			enemies_on_light.erase(key)
			break

func update():
	damage = get_damage()
	distance = get_distance()
	time_to_damage = get_time_attak()
	

func get_damage() -> int:
	print("implementar logica do get_damage: LightArmor")
	return 2

func get_distance():
	print("implementar logica do get_distance: LightArmor")
	return Vector2.ONE
	
func get_time_attak():
	print("implementar logica do get_time_attack: LightArmor")
	return 1.5
	
func set_max(max: int, type: String, is_price: bool = false):
	if is_price:
		infos["max"]["price"][type] = max
	else:
		infos["max"][type] = max
		
func set_min(min: int, type: String, is_price: bool = false):
	if is_price:
		infos["min"]["price"][type] = min
	else:
		infos["min"][type] = min
		
func upgrade(type: String):
	infos["level"][type] += 1
	
func get_price(type: String):
	print("ajeitar logica de preço", get_path())
	return infos["min"]["price"][type]
	
func set_price(amount: int):
	print("preço setado")
	infos["price"] = amount
	

	
	

	
