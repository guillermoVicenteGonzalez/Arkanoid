class_name MainMenu extends Menu



@export var first_level:PackedScene = preload("res://levels/template/level_template.tscn")

var highScoresScene:PackedScene = preload("res://UI/Menus/HighScoresMenu/HighScoresView.tscn")

@onready var settings_menu: SettingsMenu = %SettingsMenu
@onready var level_select: LevelSelectView = %levelSelect


func _on_settings_menu_back(menu:Menu) -> void:
	print_debug(menu)
	_on_child_menu_back(menu)


func _on_settings_btn_button_down() -> void:
	_navigate_to(settings_menu)


func _on_play_btn_button_down() -> void:
	_navigate_to(level_select)



func _on_high_scores_btn_button_down() -> void:
	change_to_packed_scene(highScoresScene)
	pass # Replace with function body.
