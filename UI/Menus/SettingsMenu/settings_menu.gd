class_name SettingsMenu extends Menu

var level1:PackedScene = preload("res://levels/template/level_template.tscn")


func _on_back_btn_button_down() -> void:
	back.emit(self as Menu)
	pass # Replace with function body.


func _on_load_level_btn_button_down() -> void:
	load_packed_scene(level1)
