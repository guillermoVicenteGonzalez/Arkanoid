class_name UISounds extends Node

@export var menu_root:NodePath

@export_category("sound effects")
@export var accept_effect:AudioStream
@export var cancel_effect:AudioStream
@export var focus_effect:AudioStream


# The & character is for StringNames
@onready var sounds := {
	&"accept": AudioStreamPlayer.new(),
	&"cancel": AudioStreamPlayer.new(),
	&"focus": AudioStreamPlayer.new()
}


func _ready() -> void:
	assign_sounds()
	for key in sounds:
		add_child(sounds[key])
		attach_signals(get_node(menu_root))


func play_ui_sound(sound_name:StringName):
	if sounds[sound_name]:
		sounds[sound_name].play()


func assign_sounds()->void:
	sounds[&"accept"].stream = accept_effect
	sounds[&"accept"].bus = "UI"
	sounds[&"cancel"].stream = cancel_effect
	sounds[&"cancel"].bus = "UI"
	sounds[&"focus"].stream = focus_effect
	sounds[&"focus"].bus = "UI"
	
	
# A custom Button class is needed so that if the button is a cancel button another sound is played
## Recursively runs through the node tree from "node" attaching sounds to buttons
func attach_signals(node:Node):
	print_debug(node)
	if node is Button:
		node.mouse_entered.connect(func(): play_ui_sound(&"focus"))
		node.focus_entered.connect(func(): play_ui_sound(&"focus"))
		node.pressed.connect(func(): play_ui_sound(&"accept"))
		
	if node.get_child_count() == 0:
		return 
		
	else:
		for n in node.get_children():
			attach_signals(n)
