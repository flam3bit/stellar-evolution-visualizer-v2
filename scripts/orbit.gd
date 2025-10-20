extends Node2D

var color:Color = Color.BLUE_VIOLET
@export var eccentricity:float = 0
@export var semi_major_axis:float
@export var rot_rate_deg:float = 90
@onready var semi_minor_axis:float = calc_semi_minor_axis(semi_major_axis, eccentricity)


func _draw() -> void:
	draw_circle(Vector2(calc_linear_eccen(semi_major_axis, semi_minor_axis) * Constants.AU_PX,0), semi_major_axis * Constants.AU_PX, color, false)

func _ready() -> void:
	scale.y = semi_minor_axis / semi_major_axis
	prints(scale, semi_minor_axis, semi_major_axis)
	prints(get_apocenter(), get_pericenter())

func _process(delta: float) -> void:
	var rotation_rate = deg_to_rad(rot_rate_deg) * delta
	rotate(rotation_rate)

func calc_semi_minor_axis(a:float, e:float):
	return a * sqrt(1 - (e ** 2))

func calc_linear_eccen(a:float, b:float):
	return sqrt((a ** 2) - (b ** 2))
	
func get_apocenter():
	return semi_major_axis * (1 + eccentricity)

func get_pericenter():
	return semi_major_axis * (1 - eccentricity)
