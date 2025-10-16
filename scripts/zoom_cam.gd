class_name ZoomCam extends Camera2D

var c_zoom:float = 0.01

func _ready() -> void:
	zoom = Vector2(c_zoom, c_zoom)
	
func _process(delta: float) -> void:
	do_cam_zoom(delta)

func do_cam_zoom(delta: float):
	c_zoom = clampf(c_zoom, 0.00007, 100)
	
	if Input.is_action_pressed("zoom_in"):
		c_zoom += (c_zoom * 2) * delta
	
	if Input.is_action_pressed("zoom_out"):
		c_zoom -= (c_zoom * 2) * delta
	
	if Input.is_action_pressed("reset_zoom"):
		c_zoom = 0.01
	
	zoom = Vector2(c_zoom, c_zoom)
	
