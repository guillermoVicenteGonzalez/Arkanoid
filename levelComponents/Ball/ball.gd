@tool

class_name Ball extends RigidBody2D

@onready var ball_collision: CollisionShape2D = %ballCollision
@onready var area_shape: CollisionShape2D = %areaShape

@export var speed:float = 350 : set = setSpeed
@export var shape:Shape2D : set = setShape

var direction:Vector2 = Vector2(0,1)


func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		linear_velocity = handleMovement(speed, direction, delta)

	
func handleMovement(sp:float, dir:Vector2, _delta:float)->Vector2:
	#print_debug(speed)
	#return speed * direction * delta
	return sp * dir

func setSpeed(s:float):
	speed = s
	

func setShape(nShape:Shape2D):
	shape = nShape
	# include drawn shape code here
	if ball_collision != null:
		ball_collision.shape = nShape
	
	if area_shape != null:
		area_shape.shape = nShape
	


func _on_ball_area_body_entered(body: Node2D) -> void:
	print_debug(body)
	if body is Player:
		direction = Vector2(0,-1)
	pass # Replace with function body.
