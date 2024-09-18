class_name HighScoreManager extends Node

const FILE_PATH = "user://high_scores.tres"

func _ready() -> void:
	saveHighScore("guillermo",4)
	printHighScores()

func createHighScoresResource() -> HighScores:
	var hs:HighScores = HighScores.new()
	var err = ResourceSaver.save(hs,FILE_PATH)
	if err:
		print_debug("Error creating new resource")
		return null
		
	else:
		return hs

func saveHighScore(playerName:String, score:int)->HighScores:
	if ResourceLoader.exists(FILE_PATH):
		var highScores:HighScores = ResourceLoader.load(FILE_PATH)
		highScores.addHighScore(playerName,score)
		var err = ResourceSaver.save(highScores, FILE_PATH)
		if err:
			print_debug("An error ocurred trying to save resource")
			return null
			
		return highScores
	else:
		print_debug("Resource didn't exist. Creating one")
		var hs = createHighScoresResource()
		if hs != null:
			hs.addHighScore(playerName, score)
			var err = ResourceSaver.save(hs,FILE_PATH)
			if err:
				print_debug("An error ocurred trying to save resource")
				return null
			return hs
			
		return null

func getHighScores()->Array[HighScore]:
	if ResourceLoader.exists(FILE_PATH):
		var highScores:HighScores = ResourceLoader.load(FILE_PATH)
		return highScores.getHighScores()
	else:
		print_debug("There are no highScores")
		return []

func printHighScores()->void:
	var hs:HighScores = ResourceLoader.load(FILE_PATH)
	hs.printHighScores()

func clearHighScores()->bool:
	var hs:HighScores = ResourceLoader.load(FILE_PATH)
	hs.clearHighScores()
	var err = ResourceSaver.save(hs,FILE_PATH)
	if err == null:
		print_debug("Error cleaning high scores")
		return false
	return true
