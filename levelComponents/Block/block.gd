@tool

class_name Block extends StaticBody2D

signal blockDeath

const DAMAGE_COLORS = {
	healthy = Color.WHITE,
	medium = Color.YELLOW,
	damaged = Color.BLUE_VIOLET
}

const DIFFICULTY_COLORS = {
	easy = Color.WHITE,
	medium = Color.GREEN,
	hard = Color.RED
}

enum blockType{
	easy,
	medium,
	hard
}

const DEFAULT_SIZE:Vector2 = Vector2(Constants.CELL_SIZE * 8, Constants.CELL_SIZE * 2) 

@export var size:Vector2 = DEFAULT_SIZE : set = setSize
@export var type:blockType = blockType.easy : set = setBlockType
@export_range(1,5) var outlineSize:float = 1 : set = setOutlineSize

var max_health:int = 1
var health:int = 1
var score:int = 1 
var blockColor := Color.WHITE : set = setColor
var outlineColor := Color.YELLOW : set = setOutlineColor

@onready var block_collision: CollisionShape2D = %blockCollision


##############################################################
# LIFECYCLE
##############################################################

func _ready():
	#var deleteThis := Vector2()
	size = size
	health = max_health


func _draw():
	draw_rect(Rect2(Vector2(0,0), size ),blockColor)
	draw_rect(Rect2(Vector2 (outlineSize / 2, outlineSize / 2), size - Vector2(outlineSize, outlineSize)),outlineColor,false,outlineSize,false)


##############################################################
# Actions
##############################################################

func death():
	# Particles
	blockDeath.emit()
	queue_free()


func hit():
	health -= 1
	if health <= 0:
		death()
		
	var diff = max_health - health
	if diff <= 1:
		pass
	elif diff >= 2:
		pass

##############################################################
# LIFECYCLE
##############################################################

static func instantiateBlock():
	pass


##############################################################
# Getters and setters
##############################################################

func setBlockType(nType:blockType):
	type = nType
	match type:
		blockType.easy:
			max_health = 1
			score = 1
			blockColor = DIFFICULTY_COLORS.easy
		
		blockType.medium:
			max_health = 2
			score = 2
			blockColor = DIFFICULTY_COLORS.medium
			
		blockType.hard:
			max_health = 3
			score = 3
			blockColor = DIFFICULTY_COLORS.hard
	print_debug(blockColor)

func setColor(nColor:Color):
	blockColor = nColor
	queue_redraw()


func setOutlineColor(nColor:Color):
	outlineColor = nColor
	queue_redraw()


func setOutlineSize(nSize:float):
	outlineSize = nSize
	queue_redraw()


func setSize(nSize:Vector2):
	size = nSize
	if block_collision != null:
		block_collision.shape.size = size 
		block_collision.position = size /2
		#block_collision.shape.size = size * CONSTANTS.CELL_SIZE
		#block_collision.position = size * CONSTANTS.CELL_SIZE / 2
	queue_redraw()

## If provided an argument returns the name of the type passed. Else it just returns the name of the current block type
func getBlockType(bType:blockType)->String:
	if bType != null:
		return blockType.keys()[bType]
	else:
		return blockType.keys()[type]


##############################################################
# EVENTS
##############################################################
