extends Menu

class_name InitialMenu

@export var anim: AnimationPlayer
@export var anim_control_node: Control
@export var control_node: Control

func _ready() -> void:
	set_active(true)
	
func _on_start_button_down() -> void:
	
	anim.animation_finished.connect(
		func(name):
			anim.animation_finished.connect(
				func(name):
					start_play.emit()
					set_visible_control(anim_control_node, false)
					set_active(false)
			)
			anim.play("start2")
			control_node.visible = false
	)
	
	set_visible_control(anim_control_node, true)
	anim.play("start")
	
func set_visible_control(control_node: Control, mode: bool):
	control_node.visible = mode
	
signal start_play


func _on_tutorial_button_down() -> void:
	for menu in Globals.house.menu_manager.menus:
		menu.set_active(false)
		
	Globals.house.tutorial_menu.set_active(true)
