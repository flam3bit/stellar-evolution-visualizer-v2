class_name HabitableZone extends Node2D

var star:Star
var in_bound:float = 1
var out_bound:float = 2

var too_hot:Color = Color.FIREBRICK
var habitable_zone:Color = Color.MEDIUM_SEA_GREEN
var too_cold:Color = Color.NAVY_BLUE
@export var hz_visible:bool = true

func _ready() -> void:
	pass

func _draw() -> void:
	if star == null:
		return
	var inner:float = star.get_radius_au() * 25
	draw_circle(Vector2.ZERO, Constants.AU_PX * ((inner + in_bound) / 2), too_hot, false, (in_bound - inner) * Constants.AU_PX)
	
	# habitable zone
	draw_circle(Vector2.ZERO, Constants.AU_PX * ((in_bound + out_bound) / 2), habitable_zone, false, (out_bound - in_bound) * Constants.AU_PX)

	# too cold
	var two_times = out_bound * 2
	draw_circle(Vector2.ZERO, Constants.AU_PX * ((two_times + out_bound) / 2), too_cold, false, (two_times - out_bound) * Constants.AU_PX)

func _process(_delta: float) -> void:
	visible = hz_visible
	queue_redraw()
