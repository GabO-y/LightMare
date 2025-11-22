extends Control

class_name ChestItem

@export var price: float = 0.0
@export var item_name: String = "item"
@export var label_name: Label
@export var label_price: Label
@export var type: TypeBuy
@export var accept_button: Button

enum TypeBuy {
	POWERUP, WEARPOWN
}

static func create(item_name, price, icon: Texture2D) -> ChestItem:
	
	var item = load("res://Cenas/Menus/Chest/ChestItem.tscn").instantiate() as ChestItem
	
	item.item_name = item_name
	item.price = price
		
	item.accept_button.icon = icon
	
	return item
	
func _ready() -> void:
	label_name.text = item_name
	label_price.text = str(price)

func _process(delta: float) -> void:
	if accept_button.has_focus() and Input.is_action_just_pressed("ui_accept"):
		try_buy()
	
func set_price(price: float):
	self.price = price
	label_price.text = str(self.price)

func set_item_name(item_name: String):
	self.item_name = item_name
	label_name.text = self.item_name

func try_buy():
	if price > Globals.player.coins: 
		insufficient_coins.emit()
		return
		
	item_buyed.emit(self)

func _on_button_button_down() -> void:
	try_buy()
	
signal item_buyed(item: ChestItem)

signal insufficient_coins
