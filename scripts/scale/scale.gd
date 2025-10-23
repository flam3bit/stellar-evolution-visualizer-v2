class_name ScaleArc2D extends Node2D

@export var radius:float = 1

const CIR_COLOR:Color = Color.WEB_GRAY
const AU:float = Constants.AU_PX
var font:Font = ThemeDB.fallback_font



func _draw() -> void:
	var scaled = radius * AU
	draw_circle(Vector2.ZERO,scaled, CIR_COLOR, false)
	draw_string(font, Vector2(0, 0), "{0} AU".format([radius]), HORIZONTAL_ALIGNMENT_LEFT, -1, 24234324, CIR_COLOR)
