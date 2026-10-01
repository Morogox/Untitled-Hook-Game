extends "res://Projectiles/Scripts/projectiles.gd"
class_name Hook
# adding this so i can see stuff in other scripts

enum HookState {FIRING, RETRACTING, HOOKED, IDLE}
var state := HookState.IDLE
@onready var player: Player = get_parent()
@onready var HookLine: Line2D = $Line2D

@export var min_return_dist := 50
@export var max_length := 1000
func _ready():
	super()
	top_level = true
	HookLine.top_level = true
	visible = false

func _physics_process(delta: float) -> void:
	var dst_to_player := global_position.distance_to(player.global_position)
	match (state):
		HookState.IDLE:
			global_position = player.global_position
			rotation = player.rotation
			velocity = Vector2.RIGHT.rotated(rotation) * b_speed
		HookState.FIRING:
			super(delta)
			if dst_to_player > max_length:
				change_state(HookState.RETRACTING)
		HookState.RETRACTING:
			var direction = global_position.direction_to(player.global_position)
			var movement = direction * b_speed * 2 * delta # the 2 is because *2 should be more responsive
			# than shooting it out
			if movement.length() >= dst_to_player:
				global_position = player.global_position
				change_state(HookState.IDLE)
			else:
				global_position += movement
		HookState.HOOKED:
			pass
	update_hook_line()


func change_state(s : HookState) -> void:
	match(s):
		HookState.IDLE:
			ray_cast.enabled = false
			rotation = player.rotation
			visible = false
		HookState.FIRING:
			velocity = Vector2.RIGHT.rotated(rotation) * b_speed
			visible = true
			ray_cast.enabled = true
		HookState.RETRACTING:
			ray_cast.enabled = false
		HookState.HOOKED:
			ray_cast.enabled = false
	state = s
func update_hook_line() -> void:
	HookLine.clear_points()
	HookLine.add_point(global_position)
	HookLine.add_point(player.global_position)


func _on_hit(collider: Node) -> void:
	if collider.is_in_group("Hookable") and state != HookState.RETRACTING:
		state = HookState.HOOKED
