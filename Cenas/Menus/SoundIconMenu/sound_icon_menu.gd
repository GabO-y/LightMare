extends Control

@export var on: TextureRect
@export var off: TextureRect

var is_on: float

func _ready() -> void:
	if Globals.is_mute:
		toggle(true)
		

func toggle(only_img: bool = false):
	on.visible = not on.visible
	off.visible = not on.visible
	if not only_img:
		AudioServer.set_bus_mute(0, !AudioServer.is_bus_mute(0))
		Globals.is_mute = off.visible

func _on_toggle_button_down() -> void:
	toggle()
