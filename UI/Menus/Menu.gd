class_name Menu extends Control

## The first element that should grab focus when getting shown
@export var element_to_focus:Control = null
@export var main_menu_scene:PackedScene

func _ready():
	_on_visibility_changed()
	self.visibility_changed.connect(_on_visibility_changed)

## Meant to be connected with its parent. When connected will tipically run _on_child_menu_back()
signal back(child_menu:Menu)

## hides the menu passed as parameter and shows its parent
func _on_child_menu_back(child_menu:Menu):
	child_menu.hide()
	if self is Menu:
		self.show()

## hides the current menu and shows the menu to navigate to
func _navigate_to(menu:Menu):
	self.hide()
	menu.show()

func _on_visibility_changed():
	if visible:
		if element_to_focus != null:
			element_to_focus.grab_focus()


func change_to_scene(scene_file_path:String, in_transition := "fadeToBlack", out_transition:String = "fadeFromBlack")->bool:
	if scene_file_path == null:
		return false
	
	get_tree().paused = true
	Engine.time_scale = 0

	await GlobalTransitions.play_transition(in_transition)
	get_tree().change_scene_to_file(scene_file_path)
	await GlobalTransitions.play_transition(out_transition)

	get_tree().paused = false
	Engine.time_scale = 1
	
	return true


func change_to_packed_scene(n_scene:PackedScene, in_transition := "fadeToBlack", out_transition:String = "fadeFromBlack")->bool:
	if n_scene == null:
		return false
	
	get_tree().paused = true
	Engine.time_scale = 0

	await GlobalTransitions.play_transition(in_transition)
	get_tree().change_scene_to_packed(n_scene)
	await GlobalTransitions.play_transition(out_transition)

	get_tree().paused = false
	Engine.time_scale = 1
	
	return true
	
func load_main_menu()->bool:
	if main_menu_scene != null:
		change_to_packed_scene(main_menu_scene)
		return true
		
	return false
