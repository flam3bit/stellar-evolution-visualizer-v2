class_name ScaleArc2D extends Node2D

@export var radius:float = 1

const CIR_COLOR:Color = Color.WEB_GRAY
const AU:float = Constants.AU_PX
var font:Font = ThemeDB.fallback_font


func _draw() -> void:
	var scaled = radius * AU
	var fsize = int(16 * radius)
	print(fsize)
	draw_circle(Vector2.ZERO,scaled, CIR_COLOR, false)
	draw_string(font, Vector2(scaled, 0), "{0} AU".format([radius]), HORIZONTAL_ALIGNMENT_LEFT, -1,fsize , CIR_COLOR)

func clamp_min_1(value:Variant, max_val:float):
	if value < 1:
		return 1
	else:
		return clamp(value, 1, max_val)
