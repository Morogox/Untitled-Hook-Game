extends Control
class_name HUD

@onready var health_container: HFlowContainer = $HealthContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


## Runs all updates functions in HUD
func update_hud() -> void:
	update_health()
	# add more when you add stuff to HUD

## Updates the amount of health icons shown in HUD
## based on "player_health" in GameManager.
## also only works with a max of 3, health_container
## would need to be updated for this to support more.
func update_health() -> void:
	var health_container_children = health_container.get_children()
	for i in range(health_container_children.size()):
		health_container_children[i].visible = false
	for i in range(GameManager.PlayerHealth):
		health_container_children[i].visible = true
