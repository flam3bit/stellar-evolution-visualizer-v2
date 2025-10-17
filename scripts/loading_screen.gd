class_name LoadingScreen extends CanvasLayer

signal load_finished()

@onready var ltext = $Loading
@onready var dyk = $DYK
@onready var bar = $ProgressBar

func _ready() -> void:
	dyk.text = "Did you know? {0}".format([Constants.DYK.pick_random()])

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
