extends CanvasLayer

class_name Menu

@export var manager: MenuManager
@export var is_active: bool = false

func set_active(mode: bool):
				
	if Globals.player:
		Globals.player.hud.visible = not mode
	
	get_tree().paused = mode
	set_process_unhandled_input(mode)
	set_process_input(mode)
	set_process_unhandled_key_input(mode)
	
	is_active = mode
	visible = mode
	
	manager.is_in_menu = mode

	if mode:
		manager.current_menu = self
		
		for menu in manager.menus:
			if menu != self:
				menu.set_process(false)
	else:
		if manager.current_menu == self:
			manager.current_menu = null
			
		for menu in manager.menus:
			menu.set_process(true)
			
func reset():
	set_active(false)
		
		
