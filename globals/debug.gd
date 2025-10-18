extends Node



func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed():
		var key = event.keycode
		match key:
			KEY_R:
				FluffyLogger.debug_print("Restarting!")
				Simulation.reset_simulation()
				get_tree().reload_current_scene()
			KEY_ESCAPE:
				FluffyLogger.debug_print("Quitting!")
				get_tree().quit()
