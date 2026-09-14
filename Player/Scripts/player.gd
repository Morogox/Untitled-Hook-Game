extends CharacterBody2D
var input_vector = Vector2.ZERO
@export var cursor: Node2D
enum PlayerState { IDLE, MOVING}
var state = PlayerState.IDLE
# Movement speed in pixels per second
@export var speed = 1000
@export var acceleration = 1500
@export var max_speed = 1500     
@export var friction = 4000     
@export var rotation_speed = 10

func _physics_process(delta):
	handle_rotation(delta)
	handle_input()
	handle_movement(delta)
	handle_camera_zoom()
	move_and_slide()
	
func handle_rotation(delta):
	var cursor_pos = get_global_mouse_position()#cursor.global_position
	var target_dir = (cursor_pos - global_position).normalized()
	var target_angle = target_dir.angle()
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)


func handle_input():
	input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
func handle_movement(delta):
	if input_vector != Vector2.ZERO:
		state = PlayerState.MOVING
		var target_velocity = input_vector * max_speed
		var accel_step = acceleration * delta
		accel_step = min(accel_step, target_velocity.distance_to(velocity)) # Clamp to prevent overshoot
		velocity = velocity.move_toward(target_velocity, accel_step)
	else:
		state = PlayerState.IDLE
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func handle_camera_zoom():
	Camera_Manager.update_zoom(velocity.length())
