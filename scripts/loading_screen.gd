class_name LoadingScreen extends CanvasLayer

signal load_finished()

const FACTS:Array = [
	"R136a1 is one of the most massive stars known. Its mass at least 300 M☉.",
	"Mira (Omicron Ceti) is a star in the asymptotic giant branch. The Sun will reach this stage in 7-10 billion years.",
	"O-types and hydrogen-burning Wolf-Rayet stars are unlikely to have planets.",
	"An extremely metal-poor Sun-mass star has temperatures of an A-type star.",
	"J1407b is a brown dwarf with a protoplanetary disk."]

@onready var ltext = $Loading
@onready var dyk = $DYK
@onready var bar = $ProgressBar

func _ready() -> void:
	dyk.text = "Did you know? {0}".format([FACTS.pick_random()])

func _process(_delta: float) -> void:
	var counter = ($PercTimer.time_left * -20) + 100
	bar.value = counter

func _on_timer_timeout() -> void:
	load_finished.emit()
	queue_free()
	

func _on_load_timer_timeout() -> void:
	ltext.visible_characters += 1
	if ltext.visible_characters == 11:
		ltext.visible_characters = 7
