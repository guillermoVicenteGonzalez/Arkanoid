class_name PauseMenu extends Menu

var paused:bool = false : set = set_paused

func _ready() -> void:
	toggle_menu(false)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_menu(!paused)

func toggle_menu(flag:bool = true):
	if flag:
		show()
		element_to_focus.grab_focus()
		
	else:
		hide()
		
	set_paused(flag)

func set_paused(flag:bool):
	paused = flag
	get_tree().paused = flag


func resume_game():
	toggle_menu(false)
