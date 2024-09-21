extends Menu

var high_scores_view:PackedScene = preload("res://UI/Menus/HighScoresMenu/HighScoresView.tscn")
var score:int = 0: set = setScore
var playerName:String = ""

@onready var score_label: Label = %ScoreLabel

func setScore(nScore:int):
	score = nScore
	if score_label != null:
		score_label.text = "score: " + str(score)


func saveScore():
	var err := HighScoreManagerScene.saveHighScore(playerName,score)
	if err[0] == null:
		print_debug("Error saving score")
	

func _on_player_name_text_changed(new_text: String) -> void:
	playerName = new_text
