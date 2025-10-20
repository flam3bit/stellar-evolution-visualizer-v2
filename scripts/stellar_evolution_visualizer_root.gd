extends Node

@onready var main = $Main
@onready var main_menu = $Main

func _ready() -> void:
	main.simulation = get_node("/root/Simulation")
	main_menu.simulation = get_node("/root/Simulation")
	Simulation.main_node = main

func print_entire_scene_tree_lmao(scene:Node,level=1):
	FluffyLogger.debug_print("{0}/{1}".format([scene.get_parent().name, scene.name]))
	if scene.get_children().size() > 0:
		for child in scene.get_children():
			print_entire_scene_tree_lmao(child,level + 1)
