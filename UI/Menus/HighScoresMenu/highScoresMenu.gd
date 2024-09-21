extends Control

@onready var high_scores_container: VBoxContainer = %highScoresContainer

func _ready() -> void:
	_load_high_scores()
	pass
	
func _load_high_scores():
	var highScores := HighScoreManagerScene.getHighScores()
	for score in highScores:
		var label = Label.new()
		label.text = score.playerName + ": " + str(score.score)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_FILL
		high_scores_container.add_child(label)
		
