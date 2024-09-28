@tool

class_name Ball extends RigidBody2D

const OG_SPEED = 350

# Export variables
@export var sphereColor:Color = Color.WHITE : set = setColor
@export var speed:float = 350 : set = setSpeed
@export var radius:float = 0 : set = setRadius

@export_group("Sound effects")
@export var block_hit_sound:AudioStream
@export var player_hit_sound:AudioStream
@export var wall_hit_sound:AudioStream

# public variables
var direction: int = 1

# private variables
var _shape := CircleShape2D.new() : set = _setShape

# onready variables
@onready var ball_collision: CollisionShape2D = %ballCollision
@onready var area_shape: CollisionShape2D = %areaShape
@onready var ball_audio_player: AudioStreamPlayer = %ballAudioPlayer

##############################################################
# LIFECYCLE
##############################################################

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		#linear_velocity = handleMovement(speed, direction, delta)
		linear_velocity = handleMovement(speed, direction, linear_velocity, delta)


func _draw() -> void:
	draw_circle(Vector2(0,0),radius,sphereColor, true)

##############################################################
# Actions
##############################################################

func handleMovement(sp:float, dir:int, vel:Vector2, _delta:float)->Vector2:
	#print_debug(speed)
	#return speed * direction * delta
	#return sp * dir
	vel.y = sp * dir
	return vel


func death():
	queue_free()


##############################################################
# Utils
##############################################################

func assign_collision_sound(collision:Node)->bool:
	if collision is Block and block_hit_sound != null:
		ball_audio_player.stream = block_hit_sound
		return true
		
	if collision is Wall and wall_hit_sound != null:
		ball_audio_player.stream = wall_hit_sound
		return true
		
	if collision is Player and player_hit_sound != null:
		ball_audio_player.stream = player_hit_sound
		return true
		
	return false
	
	

##############################################################
# Getters and setters
##############################################################

func setSpeed(s:float):
	speed = s


func _setShape(nShape:CircleShape2D):
	_shape = nShape
	queue_redraw()
	
	# include drawn shape code here
	if ball_collision != null:
		ball_collision.shape = nShape
	
	if area_shape != null:
		nShape.radius = nShape.radius + 2
		area_shape.shape = nShape


func setColor(nColor:Color):
	sphereColor = nColor
	queue_redraw()


func setRadius(nRadius:float):
	radius = nRadius
	_shape.radius = radius
	_shape = _shape
	queue_redraw()

##############################################################
# EVENTS
##############################################################


func _on_body_entered(body: Node) -> void:
	assign_collision_sound(body)
	if body is Player || body is Block:
		direction *= -1
		

	if body is Wall:
		if body.bounceDirection == Wall.BounceDirection.VERTICAL:
			direction *= -1

	if body is Block:
		print_debug("block")
		body.hit()
		
	ball_audio_player.play()
