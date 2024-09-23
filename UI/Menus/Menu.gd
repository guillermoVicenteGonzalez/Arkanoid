

class_name Menu extends Control

const MAIN_MENU_PATH = "res://UI/Menus/MainMenu/main_menu.tscn"


## Meant to be connected with its parent. When connected will tipically run _on_child_menu_back()
signal back(child_menu:Menu)

## The first element that should grab focus when getting shown
@export var element_to_focus:Control = null


func _ready():
	_on_visibility_changed()
	self.visibility_changed.connect(_on_visibility_changed)

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


func change_to_scene(n_scene_path:String, in_transition := "fadeToBlack", out_transition:String = "fadeFromBlack")->bool:
	if n_scene_path == null:
		return false
	
	get_tree().paused = true
	#Engine.time_scale = 0

	await GlobalTransitions.play_transition(in_transition)
	get_tree().change_scene_to_file(n_scene_path)
	await GlobalTransitions.play_transition(out_transition)

	get_tree().paused = false
	#Engine.time_scale = 1
	
	return true


func change_to_packed_scene(n_scene:PackedScene, in_transition := "fadeToBlack", out_transition:String = "fadeFromBlack")->bool:
	if n_scene == null:
		return false
	
	get_tree().paused = true
	#Engine.time_scale = 0

	await GlobalTransitions.play_transition(in_transition)
	get_tree().change_scene_to_packed(n_scene)
	await GlobalTransitions.play_transition(out_transition)

	get_tree().paused = false
	#Engine.time_scale = 1
	
	return true
	


func quit():
	get_tree().quit()
