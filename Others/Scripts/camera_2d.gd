extends Camera2D
@export var player: CharacterBody2D
var base_camera_spd = 15.0
@export var world_min = Vector2(-5120, -5120)
@export var world_max = Vector2(5120, 5120)

@export var to_mouse = 0.5

@export var dodge_effects = true

@export var tilt_amount = 10   # degrees
@export var tilt_speed = 8.0
@export var target_tilt = 0.0

@export var base_zoom = Vector2(1.0,1.0)       # normal zoom
@export var max_zoom = Vector2(0.6, 0.6) # zoom out when dodging
@export var zoom_speed = 15.0                # how quickly it lerps
var target_zoom = base_zoom

@export var camera_max_speed = 5000

func _ready():
	Camera_Manager.register(self)
	make_current()

func update_speed_zoom(speed: float):
	var speed_ratio = clamp(speed / camera_max_speed, 0.0, 1.0)
	# smoothstep gives a nicer curve than linear lerp
	speed_ratio = smoothstep(0.0, 1.0, speed_ratio)
	target_zoom = base_zoom.lerp(max_zoom, speed_ratio)
	pass

func _process(delta):
	var player_pos = player.global_position 
	var mouse_pos = get_global_mouse_position()
	
	# 30% toward cursor 
	var cam_offset = (mouse_pos - player_pos) * to_mouse
	var target_pos = player_pos + cam_offset
	#var speed_factor = clamp(player_speed / 500.0, 1.0, 3.0)  # tweak 200 and max factor as needed
	var adjusted_camera_spd = base_camera_spd #* speed_factor
	
	# Smoothly move camera toward target 
	global_position = global_position.lerp(target_pos, adjusted_camera_spd * delta)
	
	var screen_size = get_viewport_rect().size
	var half_screen = screen_size / 2
	
	# tilt
	rotation_degrees = lerp(rotation_degrees, target_tilt, tilt_speed * delta)
	# slowly reset target tilt to 0
	target_tilt = lerp(target_tilt, 0.0, tilt_speed * delta)
	
	# zoom
	zoom = zoom.lerp(target_zoom, zoom_speed * delta)
	print("current zoom ", zoom)
	# slowly reset target zoom to normal
	target_zoom = target_zoom.lerp(base_zoom, zoom_speed * delta * 0.5)
	
	# Clamp camera to stay within world bounds
	# CAUSES PROBLEM WITH THE CROSSHAIR AT EDGE OF WORLD 
	#global_position.x = clamp(global_position.x, world_min.x + half_screen.x, world_max.x - half_screen.x)
	#global_position.y = clamp(global_position.y, world_min.y + half_screen.y, world_max.y - half_screen.y)
	
	#print("Camera at " + str(global_position))
