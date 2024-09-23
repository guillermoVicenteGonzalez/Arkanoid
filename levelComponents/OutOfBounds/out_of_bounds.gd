@tool
class_name OutOfBounds extends Area2D

signal ballOut

const OUT_OF_BOUNDS_PATH = "res://levelComponents/OutOfBounds/out_of_bounds.tscn"

@export var size:Vector2 : set = setSize
var _shape := RectangleShape2D.new()

@onready var ofb_shape: CollisionShape2D = %OFBShape

static func instantiateOutOfBounds(_pos:Vector2 = Vector2(0,0))->OutOfBounds:
	var OOFScene:PackedScene = load(OUT_OF_BOUNDS_PATH)
	var OOFInstance:OutOfBounds = OOFScene.instantiate()
	OOFInstance.global_position = _pos
	return OOFInstance
	

func setSize(nSize:Vector2):
	size = nSize
	_shape.size = size
	if ofb_shape != null:
		ofb_shape.shape = _shape
		ofb_shape.position = size / 2


func _on_body_entered(body: Node2D) -> void:
	print_debug(body)
	if body is Ball:
		await body.death()
		ballOut.emit()
