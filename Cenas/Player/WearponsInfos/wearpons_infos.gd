extends Node2D

class_name WearponInfo


var wearpon_selected: armor
var wearpons: Array[armor]

func _ready() -> void:

	var lantern: armor = armor.new("lantern")
	var fairy_light: armor = armor.new("fairy_light")
	var lighter: armor = armor.new("lighter")
	
	wearpons.append_array([lantern, fairy_light, lighter])
	
	lighter.price = 70.0
	fairy_light.price = 100.0
	
	lantern.is_locked = false
	fairy_light.is_locked = false
	
	fairy_light.l_damage = 3
	fairy_light.p_damage = 30.0
	
	# logica de selecão e valores, ate ent, corretas

func has_armor(a_name: String) -> bool:
	for a in wearpons:
		if a.name == a_name.to_lower():
			return not a.is_locked
	return false
	
func get_armor(a_name: String):
	a_name = a_name.to_lower()
	for w in wearpons:
		if w.name == a_name:
			return w

class armor:
	
	var name: String
	var price: float = 0.0
	var l_damage: int = 1
	var l_distance: int = 1
	var l_time_attack: int = 1
	var p_damage: float = 10.0
	var p_distance: float = 10.0
	var p_time_attack: float = 10.0
	var is_locked: bool = true
	
	func _init(me_name: String) -> void:
		self.name = me_name.replace("_", "").to_lower()
	 
