extends Menu

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	await get_tree().process_frame
	set_active(false)
	
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_escape"):
		if !manager.current_menu and not manager.is_in_menu:
			show_menu()
		elif manager.current_menu == self:
			hide_menu()	
			
			
func show_menu():
	set_active(true)
	
func hide_menu():
	set_active(false)
	
func _on_button_pressed() -> void:
	hide_menu()

func _on_exit_button_down() -> void:
	get_tree().quit()

func _on_finish_round_pressed() -> void:
	
	if Globals.player.is_getting_key:
		hide_menu()
		return 
		
	Globals.player.take_damage(100)
	hide_menu()
