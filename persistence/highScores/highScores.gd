class_name HighScores extends Resource

@export var _highScores:Array[HighScore] = []

func addHighScore(name:String, score:int)->HighScore:
	#var hs = {"name":name, "score":score}
	var hs = HighScore.new(name,score)
	_highScores.append(hs)
	return hs
	
func getHighScores() -> Array[HighScore]:
	return _highScores

func printHighScores() -> void:
	print("printing high scores. highscores length: " + str(_highScores.size()))
	print("---------------------------------------------------------------------")
	for score in _highScores:
		score.printHighScore()
	print("---------------------------------------------------------------------")
	print_debug("printing scores finished")

func clearHighScores() -> void:
	_highScores = []
	print_debug(_highScores)

func orderHighScores()->void:
	pass
