class_name Menu extends Control

## Meant to be connected with its parent. When connected will tipically run _on_child_menu_back()
signal back(child_menu:Menu)

## hides the menu passed as parameter and shows its parent
func _on_child_menu_back(child_menu:Menu):
	child_menu.hide()
	if self is Menu:
		self.show()
	pass

## hides the current menu and shows the menu to navigate to
func _navigate_to(menu:Menu):
	self.hide()
	menu.show()
