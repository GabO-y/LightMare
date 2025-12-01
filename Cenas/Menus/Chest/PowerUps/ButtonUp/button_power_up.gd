extends TextureRect

class_name ButtonPowerUp

@export var l_price: Label
@export var l_name: Label
@export var l_value: Label

@export var bar: ProgressBar
@export var button: Button

var chest_menu: ChestMenu

var price: float = 0.0

var type: String = ""

var level: int = 1

func _ready() -> void:
	await get_tree().process_frame
	update_label()

func upgrade():
	
	var max_level = 9
	
	if type == "life":
		max_level = 8
	
	if level >= max_level:
		l_price.visible = false
		l_value.text = "MAX"
		bar.value = 10
		return

	if Globals.player.coins < price:
		chest_menu._insuffient_coisn()
		return
		
	Globals.player._spend_coins(price)
	chest_menu.update_label_coins()
	
	match type:
		
		"life":
			var max_h = Globals.player.max_heart + 1
			
			Globals.player.max_heart = max_h
			Globals.player.hearts = max_h
			
			Globals.player.update_hearts()
			price += price * 0.35
		"speed":
			Globals.player.speed_bonus += 0.05
			price += price * 0.4
		"invencible":
			Globals.player.invencible_duration_bonus += 0.1
			price += price * 0.45
			
	update_label()
		
	price = int(str("%.2f" % price))
			
	set_price(price)
	level += 1
	bar.value = level
			
func set_l_name(n: String):
	l_name.text = n
	
func set_price(price: float):
	self.price = price
	l_price.text = str(price)
	
func update_label():
	
	var result = ""
	
	match type:
		"life":
			result = str(Globals.player.max_heart, " >> ", (Globals.player.max_heart + 1))
		"speed":
			var current = str((Globals.player.speed_bonus - 1.0) * 10)
			var next = str(float(current) + (0.05 * 10))
			result = current + "% >> " + next + "%"
		"invencible":
			var current = str("%.2f" % ((Globals.player.invencible_duration_bonus - 1.0) * 10))
			var next = str("%.2f" % (float(current) + (0.05 * 10)))
			result = current + "% >> " + next + "%"
			
	l_value.text = str(result) 

func _on_button_upgrade() -> void:
	upgrade()
