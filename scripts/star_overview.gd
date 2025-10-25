class_name StarOverview extends CanvasLayer

signal overview_finished()

var star_temp:float = 5778
var star_name:String = "Sun"
var star_mass:float = 1
var star_strlength:int
var mass_strlength:int
var mist:bool

@onready var star:MainMenuStar = $Star
@onready var star_label:RichTextLabel = $StarName
@onready var mass_label:RichTextLabel = $StarMass
@onready var mode:Label = $VBoxContainer/ModeLabel
@onready var skippedms:Label = $VBoxContainer/SkippedMSLabel

func _on_ready() -> void:
	star.temperature = star_temp
	star_strlength = set_text(star_name)
	mass_strlength = set_mass(star_mass)
	set_text_anim()
	
	skippedms.visible = Options.skip_ms
	
	if mist:
		mode.text = ""
	else:
		mode.text = ""
	
func set_text(text:String):
	
	var ftext:String = text
	
	var length:int = ftext.length()
	var frmt:String = "{0}".format([ftext])
	
	star_label.text = frmt
	return length
func set_mass(val:float):
	
	var round_val = 4
	
	if val > 10 and val < 100:
		round_val = 3
	if val > 100 and val < 1000:
		round_val = 2
	if val > 1000 and val < 100000:
		round_val = 1
	if val > 100000:
		round_val = 0
		
	var mass_str:String = "Mass: " + "%.{0}f".format([round_val]) % val + " M☉"
	var length:int = mass_str.length()
	var frmt:String = "{0}".format([mass_str])
	mass_label.text = frmt
	return length

func set_text_anim():
	star_label.visible_ratio = 0
	mass_label.visible_ratio = 0
	$TextAnimationPlayer.play("StarNameAnim")
	
func _on_text_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "StarNameAnim":
		$TextAnimationPlayer.play("StarMassAnim")
	if anim_name == "StarMassAnim":
		$Delay.start()


func _on_fin_anim_animation_finished(_anim_name: StringName) -> void:
	overview_finished.emit()
	queue_free()

func _on_skip_pressed() -> void:
	overview_finished.emit()
	queue_free()
	

var star_visible:int
var mass_visible:int

func _process(_delta: float) -> void:
	name_sound($StarName)
	mass_sound($StarMass)

func name_sound(node:RichTextLabel):
	if star_visible != node.visible_characters:
		star_visible += 1
		$TypeSound.play()
	if node.visible_characters == -1:
		star_visible = -1

func mass_sound(node:RichTextLabel):
	if mass_visible != node.visible_characters:
		mass_visible += 1
		$TypeSound.play()
	if node.visible_characters == -1:
		mass_visible = -1

func _on_delay_timeout() -> void:
	$FinAnim.play("ZoomFade")
	$Trumpet.play()
