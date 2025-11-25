extends Control

class_name ArmorChestMenu

@export var chess_menu: ChestMenu
@export var armor_manager: ArmorManager

@export var damage: UpgradeSizeItem
@export var time_to_attack: UpgradeSizeItem
@export var distance: UpgradeSizeItem

@export var lantern: WearponSizeItem
@export var lighter: WearponSizeItem
@export var fairy_light: WearponSizeItem

var up_options: Array[UpgradeSizeItem]
var armor_options: Array[WearponSizeItem]

func _ready() -> void:
	
	damage.type = "damage"
	time_to_attack.type = "time_attack"
	distance.type = "distance"
	
	up_options.append_array([
		damage, time_to_attack, distance
	])
	
	armor_options.append_array([
		lantern, lighter, fairy_light
	])
	
	#armor_options.append_array([
		#lantern, lighter
	#])
	
	lantern.price_label.visible = false
	
	lighter.setup(
		"Lighter",
		"res://Assets/LightArmor/Lighter/lighter_icon.png"
		)
		
	fairy_light.setup(
		"FairyLight",
		"res://Assets/LightArmor/FairyLight/fairy_light_icon.png"
	)
	
	time_to_attack.item_icon.texture = load("res://Assets/LightArmor/AssestsUpgrades/time_to_attack.png")
	time_to_attack.item_name.text = "Tempo de Ataque"
	time_to_attack.item_name.label_settings.font_size = 31
	
	distance.item_icon.texture = load("res://Assets/LightArmor/AssestsUpgrades/distance_icon.png")
	distance.item_name.text = "Distância"

	
func _update(a_name: String):
	
	var arm = armor_manager.get_armor(a_name)
	
	for up in up_options:
		up.progress_bar.max_value = arm.general_infos.get_max_level(up.type)
		up.progress_bar.value = arm.general_infos.get_level(up.type)
		up._update_price(arm)
	
	if arm.general_infos.is_locked: return
	
	armor_manager.select_armor(arm.name)
	
	for armor in armor_options:
		if armor.name_label.text.to_lower() == arm.name.to_lower():
			armor.select()
			if armor.price_label.visible:
				armor.price_label.visible = false
				chess_menu.update_label_coins()
		else:
			armor.unselect()

func setup_sizes():

	for armor in armor_options:
		armor.armor_menu = self
		armor.armor_manager = armor_manager
		armor.setup_button()
		_update(armor.name_label.text)

	for upgrade in up_options:
		
		upgrade.armor_menu = self
		upgrade.player = chess_menu.player
		
		upgrade.setup()
		upgrade._update_price(armor_manager.get_selected_armor())
		
		
