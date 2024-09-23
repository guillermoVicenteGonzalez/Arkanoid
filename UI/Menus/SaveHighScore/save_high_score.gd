class_name SaveHighScoreView extends Menu


var high_scores_view:PackedScene = preload("res://UI/Menus/HighScoresMenu/HighScoresView.tscn")
var score:int = 0: set = setScore
var playerName:String = ""

@onready var score_label: Label = %ScoreLabel
var game_over_flag:bool : set = set_game_over_flag


func _ready():
	setScore(score)

func setScore(nScore:int):
	score = nScore
	if score_label != null:
		score_label.text = "score: " + str(score)


func saveScore():
	var err := HighScoreManagerScene.saveHighScore(playerName,score)
	if err[0] == null:
		print_debug("Error saving score")
		
	change_to_scene("res://UI/Menus/HighScoresMenu/HighScoresView.tscn")
	

func _on_player_name_text_changed(new_text: String) -> void:
	playerName = new_text


func set_game_over_flag(n_flag:bool):
	game_over_flag = n_flag
	%titleLabel.text = "Game Over"


func _on_cancel_btn_button_down() -> void:
	change_to_scene(Routes.routes.main_menu)


func _on_retry_btn_button_down() -> void:
	change_to_scene(Routes.routes.first_level)
