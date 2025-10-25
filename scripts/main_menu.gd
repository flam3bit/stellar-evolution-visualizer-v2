class_name MainMenu extends CanvasLayer

@onready var stars = [$MType, $KType, $GType, $FType, $AType, $BType, $OType]
@onready var start = $StartButton 
var preload_loading_screen:PackedScene = preload("res://scenes/loading_screen.tscn")
var preload_brief_scene:PackedScene = preload("res://scenes/star_overview.tscn")
var loading_screen:LoadingScreen
var star_overview:StarOverview

func _ready() -> void:
	loading_screen = preload_loading_screen.instantiate()
	loading_screen.load_finished.connect(remove)
	star_overview = preload_brief_scene.instantiate()
	star_overview.overview_finished.connect(_on_overview_finished)
	for star:MainMenuStar in stars:
		star.position.y = ProjectSettings.get_setting("display/window/size/viewport_height") / 2
		#star.position.y -= (Constants.SUN_PX * star.radius)
	
func add_data(path:String):
	var error = Simulation.load_sim_data(path)
	if error == OK:
		start.disabled = false

func remove(star_name:String, star_mass:float, star_temp:float, mist:bool):

	star_overview.star_name = star_name
	star_overview.star_mass = star_mass
	star_overview.star_temp = star_temp
	star_overview.mist = mist
	get_parent().add_child(star_overview)
	
func _on_overview_finished():
	Simulation.set_process(true)
	Simulation.started = true
	queue_free()

func _on_o_type_buttons_mist_chosen() -> void:
	add_data("res://examples/mist/Orinesa.stellar")

func _on_b_type_buttons_mist_chosen() -> void:
	add_data("res://examples/mist/Berigea.stellar")

func _on_a_type_buttons_mist_chosen() -> void:
	add_data("res://examples/mist/Argoth.stellar")

func _on_f_type_buttons_mist_chosen() -> void:
	add_data("res://examples/mist/Feria.stellar")

func _on_g_type_buttons_mist_chosen() -> void:
	add_data("res://examples/mist/Genor.stellar")

func _on_k_type_buttons_mist_chosen() -> void:
	add_data("res://examples/mist/Kerdo.stellar")

func _on_m_type_buttons_mist_chosen() -> void:
	add_data("res://examples/mist/Mitria.stellar")

func _on_import_button_pressed() -> void:
	create_open_file()
	
func opened_file(path:String):
	add_data(path)

func create_open_file():
	var file_dialogue:FileDialog = FileDialog.new()
	file_dialogue.file_selected.connect(opened_file)
	file_dialogue.access = FileDialog.ACCESS_FILESYSTEM
	file_dialogue.show_hidden_files = true
	file_dialogue.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialogue.filters = PackedStringArray(["*.stellar", "*.stel", "*.star"])
	file_dialogue.use_native_dialog = true
	add_child(file_dialogue)
	file_dialogue.popup_centered()

func _on_skip_ms_toggled(toggled_on: bool) -> void:
	Options.skip_ms = toggled_on
	
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	$OptionsContainer/SkipMS.button_pressed = Options.skip_ms
	$MType/MTypeButtons/MistButton.disabled = Options.skip_ms

func _on_start_button_pressed() -> void:
	get_parent().add_child(loading_screen)
	for star in stars:
		for node in star.get_children():
			for child:Button in node.get_children():
				child.disabled = true
