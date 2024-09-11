class_name Level extends Node2D


@export var size := Vector2(1280, 800)

var speed:float = 1
var score:int = 0
var _levelCenter:Vector2

@onready var player: Player = %player

func _ready() -> void:
	_levelCenter = size / 2
	initializeLevel()

static func instantiateLevel(levelSize:Vector2)-> Level:
	var l := Level.new()
	l.size = levelSize
	return l


func initializeLevel():
	# Set dimensions (camera)
	# Set player in the middle
	player.global_position = Vector2(_levelCenter.x, size.y - 50)
	createWalls(size)
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

func createWalls(levelSize:Vector2):
	var wallSize = Vector2(1,levelSize.y)
	var horizontalSize = Vector2(levelSize.x, 1)
	
	var leftWall := Wall.instantiateWall(Vector2(0,0))
	var rightWall := Wall.instantiateWall(Vector2(levelSize.x, 0))
	var topWall := Wall.instantiateWall(Vector2(0,-1))
	topWall.bounceDirection = Wall.BounceDirection.VERTICAL
	var outOfBounds := OutOfBounds.instantiateOutOfBounds(Vector2(0,levelSize.y -1))
	
	add_child(leftWall)
	add_child(rightWall)
	add_child(topWall)
	add_child(outOfBounds)
	
	leftWall.size = wallSize
	rightWall.size = wallSize
	topWall.size = horizontalSize
	outOfBounds.size = horizontalSize
	
