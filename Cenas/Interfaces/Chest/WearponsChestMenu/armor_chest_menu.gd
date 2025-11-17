extends Control

class_name ArmorChestMenu

@export var chess_menu: ChestMenu
@export var armor_manager: ArmorManager

@export var damage: UpgradeSizeItem
@export var time_to_attack: UpgradeSizeItem
@export var distamce: UpgradeSizeItem

@export var lantern: WearponSizeItem
@export var lighter: WearponSizeItem
@export var fairy_light: WearponSizeItem

var up_options: Array[UpgradeSizeItem]
var armor_options: Array[WearponSizeItem]

func _ready() -> void:
	
	up_options.append_array([
		damage, time_to_attack, distamce
	])
	
	armor_options.append_array([
		lantern, lighter, fairy_light
	])
	
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
	time_to_attack.item_name.text = "Tempo de\n Ataque"
	time_to_attack.item_name.label_settings.font_size = 31
	
	distamce.item_icon.texture = load("res://Assets/LightArmor/AssestsUpgrades/distance_icon.png")
	distamce.item_name.text = "Distância"

	
func _update(a_name: String):
	
	var arm = armor_manager.get_armor(a_name)
	
	damage.progress_bar.value = arm.infos["level"]["damage"]
	distamce.progress_bar.value =  arm.infos["level"]["distance"]
	time_to_attack.progress_bar.value =  arm.infos["level"]["time_attack"]
	
	damage.item_price.text = str(arm.get_price("damage"))
	distamce.item_price.text = str(arm.get_price("distance"))
	time_to_attack.item_price.text = str(arm.get_price("time_attack"))
	
	if arm.infos["is_locked"]: return
	
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
		_update(armor.name_label.text)

	for w in armor_options:
		w.armor_menu = self
		w.armor_manager = chess_menu.player.armor_manager
		w.setup_button()
		
