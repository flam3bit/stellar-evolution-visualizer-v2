class_name StarOverview extends CanvasLayer

var star_temp:float
var star_name:String
var star_mass:String

@onready var star = $Star

func _ready() -> void:
	star.temperature = star_temp
