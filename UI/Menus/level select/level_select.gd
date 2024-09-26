class_name LevelSelectView extends Menu

@export var level_router:LevelRouter

@onready var levels_container: VBoxContainer = %LevelsContainer

func _ready() -> void:
	load_levels()

func load_levels():
	if level_router != null:
		for level in level_router.levels:
			var btn := Button.new()
			btn.text = level.level_name
			btn.button_down.connect(change_to_packed_scene.bind(level.level_path))
			levels_container.add_child(btn)


func _on_back_btn_button_down() -> void:
	back.emit(self as Menu)
