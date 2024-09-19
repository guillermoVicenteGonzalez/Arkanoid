class_name Menu extends Control

## The first element that should grab focus when getting shown
@export var element_to_focus:Control = null

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


func load_packed_scene(s:PackedScene):
	get_tree().change_scene_to_packed(s)
	
