@tool
class_name Wall extends StaticBody2D

const WALL_SCENE_PATH = "res://levelComponents/Wall/wall.tscn"

enum BounceDirection{
	HORIZONTAL,
	VERTICAL
}

@export var size:Vector2 : set = setSize
@export var bounceDirection:BounceDirection = BounceDirection.HORIZONTAL

var _shape := RectangleShape2D.new()

@onready var wall_shape: CollisionShape2D = %wallShape


static func instantiateWall(_pos:Vector2 = Vector2(0,0))->Wall:
	var wallScene:PackedScene = load(WALL_SCENE_PATH)
	var wallInstance:Wall = wallScene.instantiate()
	wallInstance.global_position = _pos
	return wallInstance


func setSize(nSize:Vector2):
	size = nSize
	_shape.size = size
	
	if wall_shape:
		wall_shape.shape = _shape
		wall_shape.position = size/2
