extends Node

@onready var sim = $Simulation
@onready var main = $Main
@onready var main_menu = $Main

func _ready() -> void:
	main.simulation = sim
	main_menu.simulation = sim

func print_entire_scene_tree_lmao(scene:Node,level=1):
	FluffyLogger.print_debug_2("{0}/{1}".format([scene.get_parent().name, scene.name]))
	if scene.get_children().size() > 0:
		for child in scene.get_children():
			print_entire_scene_tree_lmao(child,level + 1)
