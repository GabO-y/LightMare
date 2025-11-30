extends Menu

class_name InitialMenu

@export var anim: AnimationPlayer
@export var anim_control_node: Control
@export var control_node: Control

func start():
	set_active(true)
	
	for c in anim.animation_finished.get_connections():
		anim.animation_finished.disconnect(c["callable"])
	
	set_visible_control(control_node, true)
	set_visible_control(anim_control_node, false)

	Globals.player.set_active(false)
	
func step1():
	set_visible_control(anim_control_node, true)
	anim.play("start")
	anim.animation_finished.connect(step2)
	
func step2(name):
	set_visible_control(control_node, false)
	anim.play("start2")
	
	await anim.animation_finished
	
	start_play.emit()
	anim.stop()
	set_visible_control(anim_control_node, false)
	set_active(false)

func _on_start_button_down() -> void:
	step1()
	
func set_visible_control(control_node: Control, mode: bool):
	control_node.visible = mode
	
func _on_tutorial_button_down() -> void:
	for menu in Globals.house.menu_manager.menus:
		menu.set_active(false)
		
	Globals.house.tutorial_menu.set_active(true)

func exit() -> void:
	get_tree().quit()

signal start_play
