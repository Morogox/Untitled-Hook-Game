extends CharacterBody2D

enum EnemyState {IDLE, MOVING}
var state := EnemyState.IDLE

@export var max_health : int
@export var health : int

@export var max_speed : int
@export var acceleration : int
@export var turn_speed :float
@export var friction : int
@export var hit_cooldown: int
var touching_player: bool
var target_dir : Vector2
var distance_to_player: float
@onready var nav := $NavigationAgent2D
var next_path_position: Vector2

@onready var player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta):
	handle_nav()
	handle_rotation(delta)
	handle_movement(delta)
	move_and_slide()
	handle_collision()

func handle_nav():
	nav.target_position = player.global_position
	next_path_position = nav.get_next_path_position()

func handle_rotation(delta):
	if state == EnemyState.MOVING:
		target_dir = (next_path_position  - global_position).normalized()
		var target_angle = target_dir.angle()
		rotation = lerp_angle(rotation, target_angle, turn_speed * delta)

func handle_collision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var body = collision.get_collider()
		if body.is_in_group("Player") and hit_cooldown == 0:
			touching_player = true
			hit_cooldown = 30
func handle_movement(delta):
	if !nav.is_navigation_finished or touching_player == false:
		state = EnemyState.MOVING
		var forward = Vector2.RIGHT.rotated(rotation)
		if distance_to_player > 100:
			forward = Vector2.RIGHT.rotated(rotation)
			velocity += forward * acceleration * delta
			var forward_speed = velocity.dot(forward)
			if forward_speed > max_speed:
				velocity -= forward * (forward_speed - max_speed)
		else: 
			forward = Vector2.RIGHT.rotated(rotation * 3)
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
		touching_player = false
	if hit_cooldown > 0:
		hit_cooldown -= 1
		
func take_hit():
	print("ouch!")
