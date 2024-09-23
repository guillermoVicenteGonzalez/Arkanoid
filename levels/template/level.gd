class_name Level extends Node2D

enum gameState{
	VICTORY,
	GAMEOVER
}

signal gameFinished(state:gameState)



@export_category("level config")
## Defines the size of the scenario
@export var size := Vector2(1280, 800)
## Defines how hard it is to break the blocks that will appear and how fast the ball will accelerate
@export_range(1,10) var difficulty:float = 1 : set = setDifficulty
## Defines if the limit is timed
@export var timed:bool = false 
@export var time_limit:float = 10

@export_category("references")
## A reference to a HUD object in the scene that will display various data.
@export var hud:HUD

## Used to accelerate the ball by multiplying its speed by this amount. It increases throughout the game
var speed:float = 1
var score:int = 0 : set = setScore
var _levelCenter:Vector2
var _blockNumber:int = 0
var _destroyedBlocks:int = 0


@onready var player: Player = %player

##############################################################
# LIFECYCLE
##############################################################

func _ready() -> void:
	get_tree().paused = true
	_levelCenter = size / 2
	initializeLevel()
	if timed:
		initialize_timer()
	get_tree().paused = false

##############################################################
# STATIC
##############################################################

static func instantiateLevel(levelSize:Vector2)-> Level:
	var l := Level.new()
	l.size = levelSize
	return l


##############################################################
# ACTIONS
##############################################################

func game_over():
	get_tree().paused = true
	var saveHighScorePacked := load("res://UI/Menus/SaveHighScore/save_high_score.tscn")
	var saveHighScoreScene:SaveHighScoreView = saveHighScorePacked.instantiate()
	saveHighScoreScene.score = score
	%HUD.add_child(saveHighScoreScene)
	# Show game over screen


func victory():
	get_tree().paused = true
	var saveHighScorePacked := load("res://UI/Menus/SaveHighScore/save_high_score.tscn")
	var saveHighScoreScene:SaveHighScoreView = saveHighScorePacked.instantiate()
	saveHighScoreScene.score = score
	saveHighScoreScene.title
	%HUD.add_child(saveHighScoreScene)

func initializeLevel():
	# Set dimensions (camera)
	# Set player in the middle
	player.global_position = Vector2(_levelCenter.x, size.y - 50)
	createWalls(size)
	# Set blocks
	triangleShapedBlocks()
	pass

func _setupBlocks():
	# For loop making a triangle
	# Random algorithm for types
	# Difficulty settings defines how many bad triangles
	pass

	
func _checkLevelFinished():
	# Gets triggered when a block emits the destroy signal
	# we get elements in group blocks
	# if it is 0 => _levelFinished()
	pass


## Instantiates the walls of the scene in their appropiate positions according to the stage's size
func createWalls(levelSize:Vector2):
	var wallSize = Vector2(1,levelSize.y)
	var horizontalSize = Vector2(levelSize.x, 1)
	
	var leftWall := Wall.instantiateWall(Vector2(0,0))
	var rightWall := Wall.instantiateWall(Vector2(levelSize.x, 0))
	var topWall := Wall.instantiateWall(Vector2(0,-1))
	topWall.bounceDirection = Wall.BounceDirection.VERTICAL
	var outOfBounds := OutOfBounds.instantiateOutOfBounds(Vector2(0,levelSize.y -1))
	outOfBounds.ballOut.connect(func(): gameFinished.emit(gameState.GAMEOVER))
	
	add_child(leftWall)
	add_child(rightWall)
	add_child(topWall)
	add_child(outOfBounds)
	
	leftWall.size = wallSize
	rightWall.size = wallSize
	topWall.size = horizontalSize
	outOfBounds.size = horizontalSize


## Instantiates blocks in an inverted triangle shape
func triangleShapedBlocks():
	var maxLength := size.x
	var maxHeight := size.y / 2
	var blockPos:= Vector2(0,0)
	var iterationCount = 1
	
	while blockPos.y < maxHeight:
		
		while blockPos.x < maxLength:
			createBlock(difficulty,blockPos)
			_blockNumber += 1
			blockPos.x += Block.DEFAULT_SIZE.x 
			
		blockPos.y += Block.DEFAULT_SIZE.y 
		blockPos.x = iterationCount * Block.DEFAULT_SIZE.x
		maxLength -= Block.DEFAULT_SIZE.x
		iterationCount += 1


##############################################################
# UTILS
##############################################################

## Instantiates a block taking into account its type according to the global difficulty
func createBlock(diff:float, pos:Vector2):
	var blockScene:PackedScene = load("res://levelComponents/Block/block.tscn")
	var blockInstance:Block = blockScene.instantiate()
	
	blockInstance.type =  decideBlockType(diff)
	
	blockInstance.global_position = pos
	blockInstance.blockDeath.connect(onBlockDeath)
	add_child(blockInstance)


## Uses the difficulty rate to calculate how hard a block to instantiate should be
func decideBlockType(diff:float):
	var rate = randf_range(0,10)
	
	var easyThreshold = 6
	var mediumTheshold = 9
	
	const mediumVarianceRate = .5
	const hardVarianceRate = .4
	
	easyThreshold -= diff * mediumVarianceRate
	mediumTheshold -= diff * hardVarianceRate
	
	if rate <= easyThreshold:
		return  Block.blockType.easy
	elif rate <= mediumTheshold:
		return Block.blockType.medium
	else:
		return Block.blockType.hard


func initialize_timer():
	var timer := get_tree().create_timer(time_limit)
	timer.timeout.connect(on_timeout)
	hud.set_timer(timer)
		
##############################################################
# GETTERS AND SETTERS
##############################################################

func setDifficulty(nDiff:float):
	if nDiff <= 0:
		difficulty = 0
	elif nDiff >= 10:
		difficulty = 10
	else:
		difficulty = nDiff

func setScore(nScore:int):
	score = nScore
	if hud != null:
		hud.setScore(score)
		
##############################################################
# CALLBACKS
##############################################################

## Passed to instantiated block's death signal so score is added upon their death
#func addScore(scoreToAdd:int = 1):
	#score += scoreToAdd
	#if hud != null:
		#hud.setScore(score)
		


func onBlockDeath(bScore:int = 1):
	setScore(score + bScore)
	_destroyedBlocks += 1
	if _destroyedBlocks == _blockNumber:
		gameFinished.emit(gameState.VICTORY)
		
	
func on_timeout():
	if _destroyedBlocks == _blockNumber:
		gameFinished.emit(gameState.VICTORY)
	else:
		gameFinished.emit(gameState.GAMEOVER)
##############################################################
# EVENTS
##############################################################


func _on_game_finished(state: Level.gameState) -> void:
	if state == gameState.VICTORY:
		victory()
	else:
		game_over()
