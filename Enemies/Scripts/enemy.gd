extends CharacterBody2D

enum EnemyState {IDLE, MOVING}
var state := EnemyState.IDLE

@export var max_health : int
@export var health : int

@export var max_speed : int
@export var acceleration : int
@export var turn_speed :int
@export var friction : int

var target_dir : Vector2

@onready var nav := $NavigationAgent2D
var next_path_position: Vector2

@onready var player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	handle_nav()
	handle_rotation(delta)
	handle_movement(delta)
	move_and_slide()

func handle_nav():
	nav.target_position = player.global_position
	next_path_position = nav.get_next_path_position()

func handle_rotation(delta):
	target_dir = (next_path_position  - global_position).normalized()
	var target_angle = target_dir.angle()
	rotation = lerp_angle(rotation, target_angle, turn_speed * delta)

func handle_movement(delta):
	if !nav.is_navigation_finished():
		state = EnemyState.MOVING
		var forward = Vector2.RIGHT.rotated(rotation)
		var target_velocity = forward * max_speed
		var accel_step = acceleration * delta
		accel_step = min(accel_step, target_velocity.distance_to(velocity)) # Clamp to prevent overshoot
		velocity = velocity.move_toward(target_velocity, accel_step)
	else:
		state = EnemyState.IDLE
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
