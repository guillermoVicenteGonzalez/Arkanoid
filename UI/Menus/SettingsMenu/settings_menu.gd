class_name SettingsMenu extends Menu

@onready var effects_slider: HSlider = %effectsSlider
@onready var master_slider: HSlider = %masterSlider
@onready var music_slider: HSlider = %musicSlider
@onready var ui_slider: HSlider = %uiSlider


func _ready() -> void:
	load_slider_values()

func _on_back_btn_button_down() -> void:
	back.emit(self as Menu)

func _on_save_btn_button_down() -> void:
	AUDIO_MANAGER.save_volume_settings()

func load_slider_values():
	effects_slider.value = AUDIO_MANAGER.get_bus_volume("Effects")
	music_slider.value = AUDIO_MANAGER.get_bus_volume("Music")
	ui_slider.value = AUDIO_MANAGER.get_bus_volume("UI")
	master_slider.value = AUDIO_MANAGER.get_bus_volume("Master")


func _on_music_slider_value_changed(value: float) -> void:
	AUDIO_MANAGER.set_bus_volume("Music",value)


func _on_ui_slider_value_changed(value: float) -> void:
	AUDIO_MANAGER.set_bus_volume("UI",value)


func _on_effects_slider_value_changed(value: float) -> void:
	AUDIO_MANAGER.set_bus_volume("Effects",value)


func _on_master_slider_value_changed(value: float) -> void:
	AUDIO_MANAGER.set_bus_volume("Master",value)
