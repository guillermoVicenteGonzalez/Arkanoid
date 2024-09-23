class_name HighScore extends Resource

@export var playerName:String
@export var score:int

func _init(n:String = "", s:int = 0) -> void:
	playerName = n
	score = s

func printHighScore():
	print("player name: " + playerName + " score: " + str(score))
