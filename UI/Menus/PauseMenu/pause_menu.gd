class_name PauseMenu extends Menu

var paused:bool = false : set = set_paused
const MAIN_MENU_PATH = "res://UI/Menus/MainMenu/main_menu.tscn"

func _ready() -> void:
	toggle_menu(false)

func _physics_process(_delta: float) -> void:
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


func _on_back_to_menu_btn_button_down() -> void:
	var mainMenu:PackedScene = load(MAIN_MENU_PATH)
	if mainMenu != null:
		#get_tree().change_scene_to_packed(mainMenu)
		change_to_packed_scene(mainMenu)
		
