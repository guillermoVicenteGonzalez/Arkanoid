@tool

class_name Ball extends RigidBody2D

@onready var ball_collision: CollisionShape2D = %ballCollision
@onready var area_shape: CollisionShape2D = %areaShape

@export var sphereColor:Color = Color.WHITE : set = setColor
@export var speed:float = 350 : set = setSpeed
#@export var shape:CircleShape2D: set = setShape

var _shape := CircleShape2D.new() : set = _setShape
@export var radius:float = 0 : set = setRadius
var direction:Vector2 = Vector2(0,1)


func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		linear_velocity = handleMovement(speed, direction, delta)


func _draw() -> void:
	draw_circle(Vector2(0,0),radius,sphereColor, true)

	
func handleMovement(sp:float, dir:Vector2, _delta:float)->Vector2:
	#print_debug(speed)
	#return speed * direction * delta
	return sp * dir

func setSpeed(s:float):
	speed = s
	

func _setShape(nShape:CircleShape2D):
	_shape = nShape
	radius = _shape.radius
	queue_redraw()
	
	# include drawn shape code here
	if ball_collision != null:
		ball_collision.shape = nShape
	
	if area_shape != null:
		area_shape.shape = nShape
	

func setColor(nColor:Color):
	sphereColor = nColor
	queue_redraw()
	print_debug("queue redraw ?")


func setRadius(nRadius:float):
	radius = nRadius
	_shape.radius = radius
	_shape = _shape
	queue_redraw()

	


func _on_ball_area_body_entered(body: Node2D) -> void:
	print_debug(body)
	if body is Player:
		direction = Vector2(0,-1)
