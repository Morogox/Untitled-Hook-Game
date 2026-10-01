extends CharacterBody2D
class_name Player

var input_vector = Vector2.ZERO

enum PlayerState { IDLE, HOOKED }
var state = PlayerState.IDLE

var unhook_length: float = 0.0
var starting_hook_angle: float = 0.0 # in radians
var ending_hook_angle: float = 0.0 # also in radians
var hooked_then_unhooked: bool = false

# Movement speed in pixels per second
@export var acceleration := 1500
@export var max_speed := 1500
@export var max_hooked_speed := 2500
@export var friction := 4000     
@export var rotation_speed := 10
@export var hook_length := 400
@export var hook_pull_force := 100

@export var cursor: Node2D

@onready var HookNode: Hook = $hook # node thing


func _ready() -> void:
	HookNode.max_length = hook_length
	pass

func _physics_process(delta):
	handle_rotation(delta)
	handle_input()
	handle_movement(delta)
	handle_camera_zoom()
	move_and_slide()
	
	
func handle_rotation(delta):
	var cursor_pos = get_global_mouse_position() #cursor.global_position
	var target_dir = (cursor_pos - global_position).normalized()
	var target_angle = target_dir.angle()
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)


func handle_input():
	input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if Input.is_action_just_pressed("shoot_hook") and HookNode.state == HookNode.HookState.IDLE:
		hook_fire()
		starting_hook_angle = rotation # for some bullshit reason, ROTATION goes clockwise instead
		# of like unit circle wise, i love this engine but holy god that SUCKS!!!!!!!!!!!!!

	if Input.is_action_just_released("shoot_hook") and HookNode.state != HookNode.HookState.IDLE:
		# trying to get it so that if you were hooked, then unhook, then
		# you get a burst of speed
		if HookNode.state == HookNode.HookState.HOOKED:
			unhook_length = position.distance_to(HookNode.position)
			ending_hook_angle = position.angle_to(HookNode.position) # gives angle from hooknode to player
			hooked_then_unhooked = true
		hook_retract()

func hook_fire():
	#print("Firing")
	HookNode.change_state(HookNode.HookState.FIRING) 


func hook_retract():
	#print("Retracting")
	HookNode.change_state(HookNode.HookState.RETRACTING) 
		
	
func handle_movement(delta) -> void:
	if input_vector != Vector2.ZERO:
		#state = PlayerState.MOVING
		var target_velocity := Vector2(0, 0)
		if HookNode.state == HookNode.HookState.HOOKED:
			target_velocity = input_vector * max_hooked_speed
		else:
			target_velocity = input_vector * max_speed
		var accel_step = acceleration * delta
		accel_step = min(accel_step, target_velocity.distance_to(velocity)) # Clamp to prevent overshoot
		velocity = velocity.move_toward(target_velocity, accel_step)
	else:
		#state = PlayerState.IDLE
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
	if HookNode.state == HookNode.HookState.HOOKED:
		velocity += calculate_hook_pull_force()
	
	if hooked_then_unhooked:
		 #basically, no matter what your velocity will stay the same
		 #but if you do happen to get that sweet spot where you unhook at a long distance,
		 #then multiply your speed up to a max of 1.5x
		velocity *= max(1, min(1.5, unhook_length / (hook_length / 3.0)))
		
		# this time we are just gonna use the fact that if you moved at an angle more than
		# 180 degrees from the original shot, get like a 1.3x? speed boost and is a value between
		# 90 too, so yeah?
		# also these are in radian # ZOINKS!
		
		#print("starting angle: ", starting_hook_angle * 180/PI, " ending angle: ", ending_hook_angle*180/PI)
		#
		##if starting_hook_angle < 0: starting_hook_angle += 2*PI
		##if ending_hook_angle < 0: ending_hook_angle += 2*PI
		#var difference = abs(starting_hook_angle - ending_hook_angle)
		#if difference > PI: difference = 2*PI - difference
		#print(starting_hook_angle, " ", ending_hook_angle)
		#print("difference: ", difference)
		#print("velocity boost: ", difference/2)
		## biggest value of difference is 3.14, so if 180, then 1.6x speed
		#velocity *= max(1, difference / 2)
		
		unhook_length = 0
		hooked_then_unhooked = false

func handle_camera_zoom():
	Camera_Manager.update_zoom(velocity.length() ** 1.2)
	
func calculate_hook_pull_force() -> Vector2:
	return Vector2.from_angle(position.angle_to_point(HookNode.position)) * hook_pull_force
