extends Control

class_name ButtonPowerUp

@export var button: Button
@export var item_icon: TextureRect
@export var item_name: Label
@export var item_price: Label
@export var progress_bar: ProgressBar

func _ready() -> void:
	button.button_down.connect(
		func():
			selected.emit(self.name)
	)

signal selected(my_name: String)
