class_name Star extends Node2D

# visual stuff
@export var temperature:float = 16000
@export var radius:float = 1
@export var rotating:bool

# important stuff
var luminosity:float = 1
var mass:float = 1
var age:float


@onready var glow = $Glow

var sim_control:Simulation

func _draw() -> void:
	draw_circle(Vector2.ZERO, Constants.SUN_PX, Color.WHITE, true)
	#self_modulate = StarColor.convert_k_to_rgb(temperature)

func convert_scale(value:float):
	scale = Vector2(value, value)
	
func set_color(temp:float):
	modulate = StarColor.convert_k_to_rgb(temp)
	
func _ready() -> void:
	var bar = get_node("/root/Simulation")
	sim_control = bar
	convert_scale(radius)
	set_color(temperature)

func _process(delta: float) -> void:
	if rotating:
		$Glow.rotate(deg_to_rad(90) * delta)
	set_color(temperature)
	convert_scale(radius)
	
func get_radius_sol():
	return radius
	
func get_radius_km():
	return radius * Constants.SUN_KM

func get_radius_au():
	return get_radius_km() / Constants.AU_KM

func get_temperature():
	return temperature

func get_luminosity():
	return luminosity

func _on_timer_timeout() -> void:
	return
	@warning_ignore("unreachable_code")
	if sim_control.cur_index != -90000:
		FluffyLogger.debug_print(sim_control.stage_sim_data[sim_control.cur_index])

func print_data():
	var nstring:String = "Name: {0}\n".format([Simulation.star_name])
	var mstring:String = "Mass: {0}\n".format([mass])
	var tstring:String = "Teff: {0}\n".format([temperature])
	var rstring:String = "Radi: {0}\n".format([radius])
	var lstring:String = "Lumi: {0}\n".format([luminosity])
	var astring:String = "Age: {0}\n".format([(age * 1_000_000) / 1_000_000_000])
	var sclass:String = "Spec: {0}\n".format([SpectralClass.calculate_spectral_class(temperature)])
	return "".join([nstring, mstring, tstring, rstring, lstring, astring, sclass])
	
func _to_string() -> String:
	return print_data()
	
func _unhandled_key_input(event: InputEvent) -> void:
	if Simulation.started:
		if event.is_pressed():
			match event.keycode:
				KEY_P:
					var user_folder = DirAccess.open("user://")
					if !user_folder.dir_exists("stars"):
						user_folder.make_dir("stars")
						
					var file = FileAccess.open("user://stars/{0}.dat".format([Simulation.star_name]), FileAccess.WRITE)
					FluffyLogger.print_info("Printing to", "user://stars/{0}.dat".format([Simulation.star_name]))
					file.store_line(print_data())
