extends CanvasLayer

class_name Menu

@export var manager: MenuManager
@export var is_active: bool = false
@export var focus_button: Button
@export var need_focus: bool = true

func set_active(mode: bool, principal: bool = true):
		
	if Globals.player:
		Globals.player.hud.visible = not mode
	
	if mode and need_focus:	
		focus_button.grab_focus()
	
	get_tree().paused = mode
	set_process_unhandled_input(mode)
	set_process_input(mode)
	set_process_unhandled_key_input(mode)
	
	is_active = mode
	visible = mode

	if not principal: return

	if mode:
		
		manager.current_menu = self
		manager.is_in_menu = true
		
		for menu in manager.menus:
			if menu != self:
				menu.set_active(false, false)
				
	else:
		
		if manager.current_menu == self:
			manager.current_menu = null
			manager.is_in_menu = false
			
		for menu in manager.menus:
			if menu is FinishMenu: continue
			menu.set_process(true)
			
func reset():
	set_active(false)
		
		
