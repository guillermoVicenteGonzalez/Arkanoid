class_name Level extends Node2D

@export var size := Vector2(1280, 800)

var speed:float = 1
var score:int = 0

static func instantiateLevel(levelSize:Vector2)-> Level:
	var l := Level.new()
	l.size = levelSize
	return l


func initializeLevel():
	# Set dimensions
	# Set player in the middle
	# Set walls
	# Set "goal"
	# Set blocks
	pass

func _setupBlocks():
	# For loop making a triangle
	# Random algorithm for types
	# Difficulty settings defines how many bad triangles
	pass

func _levelFinished():
	# gets triggered by event
	pass
	
func _checkLevelFinished():
	# Gets triggered when a block emits the destroy signal
	# we get elements in group blocks
	# if it is 0 => _levelFinished()
	pass
