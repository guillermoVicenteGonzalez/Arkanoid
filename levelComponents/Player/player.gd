class_name Player extends CharacterBody2D

const BASE_HEIGHT = 16
const BASE_WIDTH = 128

@onready var player_collision: CollisionShape2D = %playerCollision
@onready var player_fill: ColorRect = %playerFill

@export var res:PlayerResource : set = setResource

var size:int = 208 : set = _setSize, get = _getSize
var speed:float
var acc:float
var friction:float

var _direction:Vector2

##############################################################
# LIFECYCLE
##############################################################

func _ready() -> void:
	initializeResource(res)
	pass
	
func _physics_process(delta: float) -> void:
	_direction = handleInput()
	velocity = handleMovement(velocity, _direction, speed, acc,friction,delta)
	move_and_slide()
	pass
	
##############################################################
# Actions
##############################################################
	
func handleMovement(v:Vector2, direction:Vector2, s:float, a:float, f:float, delta:float) -> Vector2:
	if direction == Vector2.ZERO:
		return v.move_toward(Vector2.ZERO, delta * f)
	else:
		return v.move_toward(direction * s, delta * a)
		
##############################################################
# UTILS
##############################################################

func initializeResource(r:PlayerResource):
	if r.speed != null: speed = r.speed
	#if r.size != null: size = r.size
	if r.acc != null: acc = r.acc
	if r.friction != null: friction = r.friction


func handleInput()->Vector2:
	var tempDir := Vector2.ZERO
	if Input.is_action_pressed("left"): tempDir.x = -1
	if Input.is_action_pressed("right"): tempDir.x = 1
	return tempDir
	
##############################################################
# Getters and setters
##############################################################

func setResource(r:PlayerResource):
	res = r
	initializeResource(r)

##Sets the internal variable size and modifies every related node in the player scene
func _setSize(nSize:int):
	size = nSize
	var sizeVector := Vector2(size , BASE_HEIGHT) 
	player_fill.size = sizeVector
	player_fill.position = -1 *  player_fill.size / 2
	
	var nShape = RectangleShape2D.new()
	nShape.size = sizeVector
	player_collision.shape = nShape
	pass

func _getSize()->int:
	return size
	
##############################################################
# EVENTS
##############################################################
