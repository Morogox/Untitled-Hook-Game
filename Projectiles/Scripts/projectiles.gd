extends Area2D
@onready var tip := $Marker2D
@onready var sprite := $Sprite2D
@onready var ray_cast := $RayCast2D
@export var lifetime: float = 15.0   # seconds before auto-destroy
@export var destructible := true
var life_timer := 0.0
@export var damage: float = 0.0       # placeholder
@export var b_speed: float = 0.0    # placeholder

var last_pos: Vector2
var velocity: Vector2
@export var can_hit_multiple :=  false
var has_hit := false
var original_rotation

var type: String
# @export var impact_scene    #for splash sprites

@export var rotate_bullet = false

@export var force := 0.0

var hit_normal: Vector2 = Vector2.ZERO

var rotate_val := 0.0
func _ready():
	original_rotation = rotation
	velocity = Vector2.RIGHT.rotated(rotation) * b_speed

func _physics_process(delta: float) -> void:
	ray_cast.target_position = Vector2(b_speed * delta, 0)
	ray_cast.force_raycast_update()

	if ray_cast.is_colliding():
		global_position = ray_cast.get_collision_point()
		_on_hit(ray_cast.get_collider())
	else:
		global_position += velocity * delta
	
	# Auto-destroy after lifetime
	if destructible:
		life_timer += delta
		if life_timer >= lifetime:
			queue_free()
	
	rotating(rotate_bullet)

func _on_hit(collider: Node) -> void:
	if collider is Area2D:
		_on_area_entered(collider)
	elif collider is PhysicsBody2D:
		_on_body_entered(collider)
	
func _on_area_entered(area: Area2D) -> void: 
	hit_normal = get_surface_normal()

func _on_body_entered(body: Node2D) -> void:
	hit_normal = get_surface_normal()
	
func rotating(flag: bool):
	if not flag:
		return
	sprite.rotation += rotate_val


func get_surface_normal() -> Vector2:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position - velocity.normalized() * 50,
		global_position + velocity.normalized() * 50
	)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = collision_mask
	
	var result = space_state.intersect_ray(query)
	if result:
		return result.normal
	else:
		return -velocity.normalized() 

# for splash sprites, we dont have any of those right now.
#func hit_effect():
	## spawn impact effect
	#rotation = original_rotation
	#var impact = impact_scene.instantiate()
	#impact.global_position = tip.global_position
	#impact.rotation = rotation
	#
	#get_tree().current_scene.add_child(impact)
	#impact.setup(impact_data[bullet_type], hit_normal)
