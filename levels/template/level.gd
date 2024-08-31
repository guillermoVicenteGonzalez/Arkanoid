class_name Level extends Node2D

@export var size := Vector2(1280, 800)

var speed:float = 1
var score:int = 0

static func instantiateLevel(size:Vector2)-> Level:
	var l := Level.new()
	return l


func initializeLevel():
	# Set dimensions
	pass

func _setupBlocks():
	# For loop making a triangle
	# Random algorithm for types
	# Difficulty settings defines how many bad triangles
	pass
