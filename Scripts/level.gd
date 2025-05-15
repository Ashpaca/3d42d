class_name Level extends Node3D

var currentMap : Map
@onready var camera : Camera3D = $SubViewportContainer/SubViewport/Camera3D
@onready var player : Guy = $Guy
var cameraOffset : Vector3 = Vector3(0, 6.613, 7.137)
const CAMERA_VIEW : Vector2i = Vector2i(8, 4)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		if child is Map:
			currentMap = child


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var right : float = currentMap.MAX_X - CAMERA_VIEW.x
	var left : float = currentMap.MIN_X + CAMERA_VIEW.x
	var top : float =  -currentMap.MIN_Z + currentMap.BACK_Y - CAMERA_VIEW.y
	var bottom : float = -currentMap.MAX_Z + currentMap.FRONT_Y + CAMERA_VIEW.y
	
	camera.global_position = player.global_position + cameraOffset
	camera.global_position.x = clamp(left, player.global_position.x + cameraOffset.x, right)
	if camera.global_position.y - camera.global_position.z > top:
		camera.global_position.z = -top + camera.global_position.y
	if camera.global_position.y - camera.global_position.z < bottom:
		camera.global_position.y = bottom + camera.global_position.z
	
	
	
