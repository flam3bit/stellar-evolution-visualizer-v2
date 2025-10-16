class_name MainMenu extends CanvasLayer

@onready var stars = [$MType, $KType, $GType, $FType, $AType, $BType, $OType]
var simulation:Simulation

var preload_loading_screen:PackedScene = preload("res://scenes/loading_screen.tscn")
var loading_screen:LoadingScreen

func _ready() -> void:
	
	loading_screen = preload_loading_screen.instantiate()
	loading_screen.load_finished.connect(remove)
	for star:MainMenuStar in stars:
		star.position.y = ProjectSettings.get_setting("display/window/size/viewport_height")
		star.position.y -= (Constants.SUN_PX * star.radius)
	
func root_ready():
	simulation = get_parent().get_node("Simulation")

func add_data(path:String):
	var error = simulation.load_sim_data(path)
	if error == OK:
		add_child(loading_screen)

func remove():
	simulation.set_process(true)
	queue_free()

func _on_o_type_buttons_mist_chosen() -> void:
	add_data("res://examples/mist/Example_OType.mist")

func _on_o_type_buttons_starpasta_chosen() -> void:
	add_data("res://examples/sp/Example_OType.stp")

func _on_b_type_buttons_mist_chosen() -> void:
	add_data("res://examples/mist/Example_BType.mist")

func _on_b_type_buttons_starpasta_chosen() -> void:
	add_data("res://examples/sp/Example_BType.stp")

func _on_a_type_buttons_mist_chosen() -> void:
	add_data("res://examples/mist/Example_AType.mist")

func _on_a_type_buttons_starpasta_chosen() -> void:
	add_data("res://examples/sp/Example_AType.stp")

func _on_f_type_buttons_mist_chosen() -> void:
	add_data("res://examples/mist/Example_FType.mist")

func _on_f_type_buttons_starpasta_chosen() -> void:
	add_data("res://examples/sp/Example_FType.stp")

func _on_g_type_buttons_mist_chosen() -> void:
	add_data("res://examples/mist/Example_GType.mist")

func _on_g_type_buttons_starpasta_chosen() -> void:
	add_data("res://examples/sp/Example_GType.stp")

func _on_k_type_buttons_mist_chosen() -> void:
	add_data("res://examples/mist/Example_KType.mist")

func _on_k_type_buttons_starpasta_chosen() -> void:
	add_data("res://examples/sp/Example_KType.stp")

func _on_m_type_buttons_mist_chosen() -> void:
	add_data("res://examples/mist/Example_MType.mist")

func _on_m_type_buttons_starpasta_chosen() -> void:
	add_data("res://examples/sp/Example_MType.stp")
