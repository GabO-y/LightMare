extends Node2D

class_name LightArmor

@export var damage: float = 0.0
@export var time_to_damage: float = 0.0
@export var distance: Vector2 = Vector2.ONE

@export var is_active = true
@export var area: Area2D

@export var can_active: bool = true

var damage_infos: Infos = Infos.new("damage")
var distance_infos: Infos = Infos.new("distance")
var time_attack_infos: Infos = Infos.new("time_attack")

var upgrades: Array[Infos] = []

var general_infos: GeneralInfos = GeneralInfos.new()

var enemies_on_light: Dictionary[Enemy, float] = {}
var mouse_move = false

var armor_dir: Vector2 = Vector2.ZERO

func _ready() -> void:
	
	general_infos.put([
		damage_infos, 
		distance_infos,
		time_attack_infos
	])
	
	if !area: return
	
	if not is_active:
		is_active = true
		
	setup_area()
	
	toggle_activate()
	
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

	setup_area()
	
func setup_area():
	if not area: 
		if name != "FairyLight":
			print(name, "está sem uma area: ", get_path())
		return
		
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

func _update():
	damage = get_damage()
	distance = get_distance()
	
	scale = distance
	
	time_to_damage = get_time_attak()
	
func get_damage() -> float:
	return general_infos.get_value("damage")
	
func get_distance():
	return general_infos.get_value("distance")
	
func get_time_attak():
	return general_infos.get_value("time_attack")
	
func set_max(max, type: String, what: String):
			
	match what:
		"value":
			general_infos.set_max_value(max, type)
		"price":
			general_infos.set_max_price(max, type)
		"level":
			general_infos.set_max_level(max, type)

func set_min(min, type: String, what: String):	
	
	match what:
		"value":
			general_infos.set_min_value(min, type)
		"price":
			general_infos.set_min_price(min, type)
		"level":
			general_infos.set_min_level(min, type)
		
func upgrade(type: String) -> bool:
	return general_infos.upgrade_1(type)
	
func is_max(type: String):
	return general_infos.is_max(type)
	
func get_price():
	return general_infos.armor_price
	
func get_price_level(type: String):
	return general_infos.get_price_level(type)
		
func set_price(amount: int):
	general_infos.armor_price = amount

class GeneralInfos:
	
	var armor_price: float = 0.0
	var infos: Array[Infos]
	var is_locked: bool = true
	
	func put(infos: Array[Infos]):
		self.infos = infos
		
	func get_price_level(type: String) -> int:
		return _get_type(type).get_current_price_level()
				
	func upgrade(type: String, amount: int) -> bool:
		return _get_type(type).upgrade(amount)
				
	func upgrade_1(type: String) -> bool:
		return upgrade(type, 1)
				
	func _get_type(type: String) -> Infos:
		var result = null
		for info in infos:
			if info.type == type:
				result = info
				break
		return result
				
	func set_price(price: float):
		armor_price = price
		
	func set_max_price(max: float, type: String):
		_get_type(type).set_max_price(max)
	
	func set_min_price(min: float, type: String):
		_get_type(type).set_min_price(min)
		
	func set_max_level(max, type: String):
		_get_type(type).set_max_level(max)
		
	func set_min_level(min: int, type: String):
		_get_type(type).set_min_level(min)
		
	func set_max_value(max, type: String):
		_get_type(type).max_value = max
		
	func set_min_value(min, type: String):
		_get_type(type).min_value = min
		
	func get_value(type: String):
		return _get_type(type).get_value()
		
	func get_max_level(type: String):
		return _get_type(type).level_infos.max_level
		
	func is_max(type: String):
		return _get_type(type).is_max()
		
	func get_level(type: String) -> int:
		return _get_type(type).level_infos.level
		
	func get_test(type):
		_get_type(type).test
	
class Infos:
	
	var type: String = ""
	var value
	var min_value
	var max_value
	
	func _init(type: String) -> void:
		self.type = type
	
	var price_infos: PriceInfos = PriceInfos.new()
	var level_infos: LevelInfos = LevelInfos.new()
	
	func set_max_price(max: float):
		price_infos.max_price_level = max
	
	func set_min_price(min: float):
		price_infos.min_price_level = min
	
	func set_max_level(max):
		level_infos.max_level = max
	
	func set_min_level(min):
		level_infos.min_level = min
		
	func set_min_value(min):
		min_value = min
		
	func set_max_value(max):
		max_value = max
		
	func get_value():
		
		var level = level_infos.level as float
		
		if level == 1:
			return min_value
	
		var max_level = level_infos.max_level
		var min_level = level_infos.min_level 
	
		var level_p = level / max_level
		
		var mid_value = max_value - min_value
		
		var t = level_p * mid_value
		
		var result = min_value + t
		
		return result
		
	func get_current_price_level():
		
		var max = price_infos.max_price_level as float
		var min = price_infos.min_price_level as float
		
		var n = level_infos.level as float

		var t = (n + 1) / level_infos.max_level
	
		var mid = max - min
		
		var v = float(mid * t)

		var result = min + v
		
		return int(result)
		
	func is_max() -> bool:
		return level_infos.level >= level_infos.max_level
		
	func upgrade(amount: int) -> bool:
		var has_money: bool = Globals.player.coins >= get_current_price_level()
		var can_upgrade = not is_max() and has_money
		
		if can_upgrade:
			level_infos.level += amount
		
		return can_upgrade
			
	func upgrade_1():
		upgrade(1)
	
class PriceInfos:
	var max_price_level: float = 0.1
	var min_price_level: float = 0.0
	
class LevelInfos:
	var level: int = 1
	
	var max_level: int = 10
	var min_level: int = 1

	
