extends CharacterBody2D
var input_vector = Vector2.ZERO
@export var cursor: Node2D
enum PlayerState { IDLE, MOVING, HOOKED }
var state = PlayerState.IDLE
# Movement speed in pixels per second
@export var speed = 1000
@export var acceleration = 1500
@export var max_speed = 1500     
@export var friction = 4000     
@export var rotation_speed = 10
@export var hook_length = 400

@onready var HookNode: Node2D = $Hook # node thing
@onready var HookRayCast: RayCast2D = $HookLineCast # update this if we move player hierachy(?) (idk how to spell)
@onready var HookLine: Line2D = $HookLine # line connecting player and hook

func _ready() -> void:
	# just in case you want to change hook_length from inspector
	HookRayCast.target_position = Vector2(hook_length, 0)
	HookNode.top_level = true
	HookLine.top_level = true

func _physics_process(delta):
	handle_rotation(delta)
	handle_input()
	handle_movement(delta)
	handle_camera_zoom()
	move_and_slide()
	update_hook_line()
	
func handle_rotation(delta):
	var cursor_pos = get_global_mouse_position() #cursor.global_position
	var target_dir = (cursor_pos - global_position).normalized()
	var target_angle = target_dir.angle()
	rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)


func handle_input():
	input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	# maybe not the best way to check for this, but we're seeing
	# if the mouse is just clicked in here.
	if Input.is_action_just_pressed("shoot_hook"):
		# basically, if the raycast is actually hitting something
		if HookRayCast.is_colliding():
			# then we can do whatever we want with the point of collision
			# just make sure to use is_colliding() before calling get_collision_point()
			# i tried it without it and it was just giving me the last collision point
			# so yeah make sure to stick with that
			HookNode.global_position = HookRayCast.get_collision_point()
			HookNode.rotation = rotation
			HookNode.visible = true
			HookLine.visible = true
		else:
			HookNode.visible = false
			HookLine.visible = false
		pass
	
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
	
func update_hook_line() -> void:
	HookLine.clear_points()
	HookLine.add_point(position)
	HookLine.add_point(HookNode.position)
