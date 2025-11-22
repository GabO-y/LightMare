extends Node2D

class_name ArmorManager

@export var player: Player
@export var chess_menu: ChestMenu

@export var armor_node: Node2D

var selected_armor: LightArmor
var armors: Array[LightArmor]

func _ready() -> void:
	
	for name in ["Lantern", "Lighter", "FairyLight"]:
		var path: String = str("res://Cenas/LightArmor/", name, "/", name, ".tscn")
		var armor = load(path).instantiate() as LightArmor

		armor._ready()

		if name == "Lantern":
			armor.general_infos.is_locked = false
			selected_armor = armor
		
		armors.append(armor)
		
	change_to_select()
		
func get_selected_armor():
	selected_armor._update()
	return selected_armor
	
func get_armor(armor_name: String) -> LightArmor:
	for armor in armors:
		if armor.name.to_lower() == armor_name.to_lower():
			return armor
	return null
	
func select_armor(armor_name: String) -> LightArmor:
	
	var target = get_armor(armor_name)
	
	if not target:
		target = get_armor("Lantern")
		
	selected_armor = target
	
	change_to_select()
	
	return selected_armor
	
func change_to_select():
	for child in player.armor_node.get_children():
		player.armor_node.remove_child(child)
		
	if !selected_armor:
		selected_armor = get_armor("Lantern")
		
	player.set_armor(selected_armor)
	
func try_buy(armor_name: String) -> bool:
	
	var armor_target: LightArmor
	
	for armor in armors:
		if armor.name.to_lower() == armor_name.to_lower():
			armor_target = armor
			break
			
	if not armor_target:
		return false
		
	if not armor_target.general_infos.is_locked:
		selected_armor = armor_target
		change_to_select()
		return true
		
	print("aqui: ", player.coins >= armor_target.get_price())
		
	if player.coins >= armor_target.get_price():
		player._spend_coins(armor_target.get_price())
		armor_target.general_infos.is_locked = false
		return true
	else:
		chess_menu._insuffient_coisn()
		return false
