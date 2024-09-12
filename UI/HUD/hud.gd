class_name HUD extends CanvasLayer

var score:int = 0 :set = setScore

@onready var score_label: Label = %scoreLabel

func ready():
	setScore(score)

func setScore(nScore:int):
	score = nScore
	if(score_label != null):
		score_label.text = "score: " + str(score)
	else:
		print_debug("the fucking label is null. FUCK ME")
	
