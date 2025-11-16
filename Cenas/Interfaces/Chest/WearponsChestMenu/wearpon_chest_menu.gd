extends Control

class_name WearponMenu

var wearpon_infos: WearponInfo

@export var damage: ButtonPowerUp
@export var time_to_attack: ButtonPowerUp
@export var distamce: ButtonPowerUp

@export var lantern: Button
@export var lighter: Button
@export var fairy_light: Button

var up_options: Array[ButtonPowerUp]
var armor_options: Array[Button]

func _ready() -> void:
	
	up_options.append_array([
		damage, time_to_attack, distamce
	])
	
	armor_options.append_array([
		lantern, lighter, fairy_light
	])
	
	time_to_attack.item_icon.texture = load("res://Assets/LightArmor/AssestsUpgrades/time_to_attack.png")
	time_to_attack.item_name.text = "Tempo de\n Ataque"
	time_to_attack.item_name.label_settings.font_size = 31
	
	distamce.item_icon.texture = load("res://Assets/LightArmor/AssestsUpgrades/distance_icon.png")
	distamce.item_name.text = "Distância"
	
	for a in armor_options:
		a.button_down.connect(
			func():
				_update(a.name)
		)
	

func _update(a_name: String):
	
	if not wearpon_infos.has_armor(a_name):
		return
		#logica para o tremilique
		
	var arm = wearpon_infos.get_armor(a_name)
	
	damage.progress_bar.value = arm.l_damage
	distamce.progress_bar.value = arm.l_distance
	time_to_attack.progress_bar.value = arm.l_time_attack
	
	damage.item_price.text = str(arm.p_damage)
	distamce.item_price.text = str(arm.p_distance)
	time_to_attack.item_price.text = str(arm.p_time_attack)
