class_name AudioManager extends Node

signal bus_changed(b_name:String)

const CONFIG_FILE_PATH = "user://settings.cfg"
const SECTION_NAME = "Sound"

func _ready() -> void:
	load_volume_settings()

func set_bus_volume(b_name:String, n_vol:float)->bool:
	var b_idx := AudioServer.get_bus_index(b_name)
	if b_idx == -1: 
		print_debug("Error retrieving bus index: The bus does not exist")
		return false
	#AudioServer.set_bus_volume_db(3)
	AudioServer.set_bus_volume_db(b_idx,linear_to_db(n_vol))
	bus_changed.emit(b_name)
	return true

func get_bus_volume(b_name)->int:
	var b_idx := AudioServer.get_bus_index(b_name)
	if b_idx == -1: 
		print_debug("Error retrieving bus index: The bus does not exist")
		return false
	var volume := AudioServer.get_bus_volume_db(b_idx)
	return db_to_linear(volume)


func save_volume_settings():
	var config := ConfigFile.new()
	for b_idx in AudioServer.bus_count:
		var b_name := AudioServer.get_bus_name(b_idx)
		var b_volume := get_bus_volume(b_name)
		config.set_value(SECTION_NAME,b_name,b_volume)
	var err := config.save(CONFIG_FILE_PATH)
	if err:
		print_debug(err)
		return false
	return true


func load_volume_settings():
	var config := ConfigFile.new()
	var err := config.load(CONFIG_FILE_PATH)
	if err:
		print_debug("The file cannot be opened. Creating another one")
		save_volume_settings()
	for key in config.get_section_keys(SECTION_NAME):
		var volume = config.get_value(SECTION_NAME,key)
		set_bus_volume(key,volume)
