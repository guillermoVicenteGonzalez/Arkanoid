class_name MainMenu extends Menu

@export var first_level:PackedScene = preload("res://levels/template/level_template.tscn")

@onready var settings_menu: SettingsMenu = %SettingsMenu


func _on_settings_menu_back(menu:Menu) -> void:
	print_debug(menu)
	_on_child_menu_back(menu)





func _on_settings_btn_button_down() -> void:
	_navigate_to(settings_menu)


func _on_play_btn_button_down() -> void:
	change_to_packed_scene(first_level)
