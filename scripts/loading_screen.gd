class_name LoadingScreen extends CanvasLayer

signal load_finished(star_name:String, star_mass:float, star_temp:float, mode:bool)

@onready var ltext = $Loading
@onready var dyk = $DYK
@onready var bar = $ProgressBar
@onready var post_load = $PostLoad
var sim:Simulation

func _ready() -> void:
	sim = get_parent().get_node("Simulation")
	dyk.text = "Did you know? {0}".format([Constants.DYK.pick_random()])

func _process(_delta: float) -> void:
	var counter = ($PercTimer.time_left * (-100.0 / $PercTimer.wait_time)) + 100
	bar.value = counter

func _on_timer_timeout() -> void:
	var init_mass:float = sim.mass_sim_data[0]
	var ms_temp:float
	var star_name:String = sim.star_name
	if sim.mist:
		var idx:int
		for stage_val_idx in sim.stage_sim_data.size():
			if sim.stage_sim_data[stage_val_idx] == Constants.MIST_MS:
				idx = stage_val_idx
				break
		ms_temp = sim.teff_sim_data[idx]
	else:
		ms_temp = sim.teff_sim_data[0]
	load_finished.emit(star_name, init_mass, ms_temp, sim.mist)
	post_load.start()

func _on_load_timer_timeout() -> void:
	ltext.visible_characters += 1
	if ltext.visible_characters == 11:
		ltext.visible_characters = 7
		
func _on_post_load_timeout() -> void:
	queue_free()
