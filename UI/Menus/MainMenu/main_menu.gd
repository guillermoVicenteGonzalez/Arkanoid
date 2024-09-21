class_name MainMenu extends Menu

@onready var settings_menu: SettingsMenu = %SettingsMenu


func _on_settings_menu_back(menu:Menu) -> void:
	print_debug(menu)
	_on_child_menu_back(menu)



func _on_settings_btn_button_down() -> void:
	_navigate_to(settings_menu)
