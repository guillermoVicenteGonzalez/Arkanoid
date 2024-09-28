class_name PauseMenu extends Menu

var paused:bool = false : set = set_paused

@onready var settings_menu: SettingsMenu = %SettingsMenu

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
	change_to_scene(Routes.routes.main_menu)


func _on_options_btn_button_down() -> void:
	_navigate_to(settings_menu)


func _on_settings_menu_back(child_menu: Menu) -> void:
	_on_child_menu_back(child_menu)
