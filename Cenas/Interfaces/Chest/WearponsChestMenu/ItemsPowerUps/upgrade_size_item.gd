extends Control

class_name UpgradeSizeItem

@export var button: Button
@export var item_icon: TextureRect
@export var item_name: Label
@export var item_price: Label
@export var progress_bar: ProgressBar

@export var player: Player
@export var armor_menu: ArmorChestMenu

var type: String

func _ready() -> void:
	button.button_down.connect(try_upgrade)
	
func setup():
	match  item_name.text.replace("\n", "").to_lower():
		"dano": type = "damage"
		"distância": type = "distance"
		"tempo de ataque": type = "time_attack"

func try_upgrade():
		
	if player.coins <= int(item_price.text):
		armor_menu.chess_menu._insuffient_coisn()
		return
				
	var armor = armor_menu.armor_manager.get_selected_armor()
		
	var price = armor.general_infos.get_price_level(type)
		
	if armor.upgrade(type):
		
		player._spend_coins(price)
		
		armor_menu.chess_menu.update_label_coins()
		
		_update_price(armor)
		
		armor._update()
		armor_menu._update(armor.name)
		
func _update_price(armor: LightArmor):
		if armor.is_max(type):
			item_price.text = "MAX"
		else:
			item_price.text = str(armor.get_price_level(type))
			
signal selected(my_name: String)
