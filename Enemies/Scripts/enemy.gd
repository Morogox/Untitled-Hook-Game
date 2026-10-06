extends CharacterBody2D

enum EnemyState {IDLE, MOVING}
var state := EnemyState.IDLE

@export var max_health : int
@export var health : int

@export var max_speed : int
@export var acceleration : int
@export var turn_speed :float
@export var friction : int

var target_dir : Vector2

@onready var nav := $NavigationAgent2D
var next_path_position: Vector2

@onready var player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta):
	handle_nav()
	handle_rotation(delta)
	handle_movement(delta)
	move_and_slide()

func handle_nav():
	nav.target_position = player.global_position
	next_path_position = nav.get_next_path_position()

func handle_rotation(delta):
	if state == EnemyState.MOVING:
		target_dir = (next_path_position  - global_position).normalized()
		var target_angle = target_dir.angle()
		rotation = lerp_angle(rotation, target_angle, turn_speed * delta)

func handle_movement(delta):
	if !nav.is_navigation_finished():
		state = EnemyState.MOVING
		var forward = Vector2.RIGHT.rotated(rotation)
		velocity += forward * acceleration * delta
		var forward_speed = velocity.dot(forward)
		if forward_speed > max_speed:
			velocity -= forward * (forward_speed - max_speed)

		# Reduce sideways drifting
		var sideways = velocity - forward * velocity.dot(forward)
		velocity -= sideways * friction * delta
		
	else:
		state = EnemyState.IDLE
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
func take_hit():
	print("ouch!")
