class_name SPMistButtons extends HBoxContainer

signal mist_chosen()
signal starpasta_chosen()

func _on_mist_button_pressed() -> void:
	mist_chosen.emit()

func _on_starpasta_button_pressed() -> void:
	starpasta_chosen.emit()
