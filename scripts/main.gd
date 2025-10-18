class_name VisualStuff extends Node

@onready var star = $Star
@onready var hz = $HabitableZone
@onready var star_name = $CanvasLayer/StarInfo/StarName
var simulation:Simulation
func _ready() -> void:
	
	FluffyLogger.print_info("Stella says hi! :3")
	#Simulation.load_sim_data("/home/flamebit/Downloads/Tairu.mist")

func root_ready():
	simulation.habitable_zone = hz
	simulation.star = star

func _process(_delta: float) -> void:
	set_temp_text(star.temperature)
	set_lum_text(star.luminosity)
	set_rad_text(star.radius)
	set_mass_text(star.mass)
	set_age_label(star.age)
	
func set_temp_text(val:float):
	var teff_text = $CanvasLayer/StarInfo/TeffVal
	
	teff_text.text = "[color={0}]{1} K[/color]".format([StarColor.convert_k_to_rgb(val).to_html(false), int(val)])

func set_lum_text(val:float):
	var lum_text = $CanvasLayer/StarInfo/LumVal
	
	var round_val = 4
	
	if val > 10 and val < 100:
		round_val = 3
	if val > 100 and val < 1000:
		round_val = 2
	if val > 1000 and val < 100000:
		round_val = 1
	if val > 100000:
		round_val = 0
	
	var format:String = "%.{0}f".format([round_val]) % val
	lum_text.text = "[color=navajowhite]{0} L☉[/color]".format([format])


const UNITS:Dictionary = {
	Constants.UNIT_KM: "km",
	Constants.UNIT_EARTH: "R♁",
	Constants.UNIT_JUPITER: "R♃",
	Constants.UNIT_SOL: "R☉",
	Constants.UNIT_AU: "AU"
}

func set_rad_text(val:float):
	var unit = Constants.UNIT_SOL
	if(val * Constants.SUN_KM) >= Constants.AU_KM * 0.5:
		val *= Constants.SUN_KM
		val /= Constants.AU_KM
		unit = Constants.UNIT_AU
	else:
		if (val * Constants.SUN_KM) <= Constants.JUPITER_KM * 5:
			val *= Constants.SUN_KM
			if val >= Constants.JUPITER_KM:
				val /= Constants.JUPITER_KM
				unit = Constants.UNIT_JUPITER
			else:
				if val <= Constants.EARTH_KM * 0.1:
					unit = Constants.UNIT_KM
				else:
					val /= Constants.EARTH_KM
					unit = Constants.UNIT_EARTH
		else:
			unit = Constants.UNIT_SOL
	
	var rad_text = $CanvasLayer/StarInfo/RadVal
	
	var round_val = 4
	
	if val > 10 and val < 100:
		round_val = 3
	if val > 100 and val < 1000:
		round_val = 2
	if val > 1000 and val < 100000:
		round_val = 1
	if val > 100000:
		round_val = 0
	
	var format:String = "%.{0}f".format([round_val]) % val
	
	rad_text.text = "[color=lightgreen]{0} {1}[/color]".format([format, UNITS[unit]])

func set_mass_text(val:float):
	var mass_text = $CanvasLayer/StarInfo/MassVal
	
	var round_val = 4
	
	if val > 10 and val < 100:
		round_val = 3
	if val > 100 and val < 1000:
		round_val = 2
	if val > 1000 and val < 100000:
		round_val = 1
	if val > 100000:
		round_val = 0
	
	var format:String = "%.{0}f".format([round_val]) % val
	mass_text.text = "[color=lightskyblue]{0} M☉[/color]".format([format])

func set_age_label(val:float):
	var age_text = $CanvasLayer/AgeContainer/AgeLabel
	
	var format:String = "%.2f" % val
	
	age_text.text = "{0} Ma".format([format])

func set_star_name(text:String):
	star_name.text = text

func _on_pause_toggled(toggled_on: bool) -> void:
	Simulation.pause_sim(toggled_on)
