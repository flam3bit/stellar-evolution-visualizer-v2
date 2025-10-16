extends Node



func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed():
		var key = event.keycode
		match key:
			KEY_R:
				FluffyLogger.print_debug_2("Restarting!")
				get_tree().reload_current_scene()
			KEY_ESCAPE:
				FluffyLogger.print_debug_2("Quitting!")
				get_tree().quit()
