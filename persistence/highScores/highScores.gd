class_name HighScores extends Resource

@export var _highScores:Array[HighScore] = []

func addHighScore(name:String, score:int)->HighScore:
	#var hs = {"name":name, "score":score}
	var hs = HighScore.new(name,score)
	_highScores.append(hs)
	sortHighScores()
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

func sortHighScores()->void:
	_highScores.sort_custom(func(a:HighScore,b:HighScore):
		if a.score > b.score:
			return true
		return false
	)
	pass
