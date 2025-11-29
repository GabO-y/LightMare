extends Control

class_name WearponSizeItem

@export var button: Button
@export var name_label: Label
@export var price_label: Label

@export var audio: AudioStreamPlayer

var armor_manager: ArmorManager
var armor_menu: ArmorChestMenu

var is_to_play: bool = true


func select():
	
	if armor_menu:
		for w in armor_menu.armor_options:
			w.unselect()
	
	name_label.modulate = Color.GREEN
	
func unselect():
	name_label.modulate = Color.WHITE
	
func setup(name_item: String, path_icon: String):
	var img = load(path_icon)
	button.icon = img
	name_label.text = name_item
	
func setup_button():
	
	var price = armor_manager.get_armor(name_label.text).get_price()
	
	price_label.text = str(price)
	
	button.button_down.connect(_press_button)
	
func _press_button():
	if armor_manager.try_buy(name_label.text):
		
		if is_to_play and name_label.text != "Lantern":
			audio.play()
			is_to_play = false
			
		armor_menu._update(name_label.text)
		
