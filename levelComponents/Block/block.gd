@tool

class_name Block extends StaticBody2D

signal blockDeath(score:int)

const BORDER_COLOR := Color.BLACK

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
@export_range(0.1,1) var borderSize:float = 0 : set = setBorderSize

var max_health:int = 1
var health:int = 1
var score:int = 1 
var blockColor := Color.WHITE : set = setColor
var outlineColor := DAMAGE_COLORS.healthy : set = setOutlineColor

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
	draw_rect(Rect2(Vector2 (borderSize / 2, borderSize / 2), size - Vector2(borderSize, borderSize)),BORDER_COLOR,false,borderSize,false)


##############################################################
# Actions
##############################################################

func death():
	# Particles
	blockDeath.emit(score)
	queue_free()


func hit():
	health -= 1
	if health <= 0:
		death()
		
	var diff = max_health - health
	if diff <= 1 and max_health > 2:
		outlineColor = DAMAGE_COLORS.medium
	elif diff >= 2 or max_health <= 2:
		outlineColor = DAMAGE_COLORS.damaged

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

func setColor(nColor:Color):
	blockColor = nColor
	queue_redraw()


func setOutlineColor(nColor:Color):
	outlineColor = nColor
	queue_redraw()


func setOutlineSize(nSize:float):
	outlineSize = nSize
	queue_redraw()

func setBorderSize(nSize:float):
	borderSize = nSize
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
