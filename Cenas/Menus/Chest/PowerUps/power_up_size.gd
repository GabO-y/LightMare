extends Control

class_name PowerUpSize

@export var perm_node: Control
@export var temp_node: Control

@export var chest_menu: ChestMenu

var perm_array: Array[ButtonPowerUp] = []

var life_button: ButtonPowerUp = load("res://Cenas/Menus/Chest/PowerUps/ButtonUp/ButtonPowerUp.tscn").instantiate()
var speed_button: ButtonPowerUp = load("res://Cenas/Menus/Chest/PowerUps/ButtonUp/ButtonPowerUp.tscn").instantiate()
var inv_time_button: ButtonPowerUp = load("res://Cenas/Menus/Chest/PowerUps/ButtonUp/ButtonPowerUp.tscn").instantiate()

func _ready() -> void:
	
	perm_array.append_array([
		life_button, speed_button, inv_time_button
	])
	
	for b in perm_array:
		perm_node.add_child(b)

	var names = ["Vida", "Velocidade", "Tempo de Invesibilidade"]
	var types = ["life", "speed", "invencible"]
	
	var prices = [10, 10, 20]
	
	for i in range(3):
		var b = perm_array.get(i)
		b.chest_menu = chest_menu
		
		b.type = types.get(i)
		b.set_price(prices.get(i))
		
		b.set_l_name(names.get(i))
