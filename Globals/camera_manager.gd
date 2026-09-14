extends Node
var current_camera: Camera2D = null

func register(cam: Camera2D):
	current_camera = cam
	
func update_zoom(speed: float):
	if current_camera:
		current_camera.update_speed_zoom(speed)
