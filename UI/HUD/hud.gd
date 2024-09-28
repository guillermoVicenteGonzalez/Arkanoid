class_name HUD extends CanvasLayer

var score:int = 0 :set = setScore
var _timer:SceneTreeTimer = null: set = set_timer
var time_left:float = 0 : set = set_time_left

@onready var score_label: Label = %scoreLabel
@onready var time_label: Label = %timeLabel

func ready():
	setScore(score)


func _physics_process(_delta: float) -> void:
	if _timer:
		set_time_left(_timer.time_left)

func setScore(nScore:int):
	score = nScore
	if(score_label != null):
		score_label.text = "score: " + str(score)
	else:
		print_debug("the fucking label is null. FUCK ME")
	

func set_timer(n_timer:SceneTreeTimer):
	if not time_label.visible && n_timer != null:
		time_label.show()
	_timer = n_timer
	set_time_left(_timer.time_left)
	
	

func set_time_left(n_time:float):
	time_left = n_time
	if time_label:
		time_label.text = "time left: " + str(snapped(time_left,0.01))
