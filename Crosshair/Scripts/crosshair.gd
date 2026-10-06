extends Node2D

@onready var cursor_pos := get_global_mouse_position()


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN) # hide system cursor

func _process(_delta):
	#position = get_viewport().get_mouse_position()
	cursor_pos = get_global_mouse_position()
	global_position = cursor_pos
