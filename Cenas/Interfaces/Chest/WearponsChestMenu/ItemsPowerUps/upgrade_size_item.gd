extends Control

class_name UpgradeSizeItem

@export var button: Button
@export var item_icon: TextureRect
@export var item_name: Label
@export var item_price: Label
@export var progress_bar: ProgressBar

@export var player: Player
@export var armor_menu: ArmorChestMenu

func _ready() -> void:
	pass
	
func setup_button():
	button.button_down.connect(try_upgrade)
	
func try_upgrade():
	
	if player.coins <= float(item_price.text):
		armor_menu.chess_menu._insuffient_coisn()
		return
		
	print(item_name.text)
		
	match  item_name.text:
		"Dano":
			var infos = armor_menu.armor_manager.get_armor(item_name.text).upgrade("damage")
			player._spend_coins(infos.get_damage_price())

			
						
func _update_price(amount: int):
	item_price.text = str(amount)
	
signal selected(my_name: String)
