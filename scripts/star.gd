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

func get_radius_earth():
	return get_radius_km() / Constants.EARTH_KM
	
func get_radius_jupiter():
	return get_radius_km() / Constants.JUPITER_KM

func get_radius_au():
	return get_radius_km() / Constants.AU_KM

var get_radius_units:Dictionary = {
	Constants.UNIT_KM: get_radius_km(),
	Constants.UNIT_EARTH: get_radius_earth(),
	Constants.UNIT_JUPITER: get_radius_jupiter(),
	Constants.UNIT_SOL: get_radius_sol(),
	Constants.UNIT_AU: get_radius_au()
}

func get_radius(unit=Constants.UNIT_SOL):
	for units in Constants.UNITS_ARRAY:
		if units == unit:
			return get_radius_units[unit]

func get_temperature():
	return temperature

func get_luminosity():
	return luminosity

func _on_timer_timeout() -> void:
	return
	@warning_ignore("unreachable_code")
	FluffyLogger.print_info(sim_control.cur_index, sim_control.age_sim_data.size() - 1, sim_control.frac)
