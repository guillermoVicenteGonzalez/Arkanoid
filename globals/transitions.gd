class_name Transitions extends CanvasLayer

@onready var transition_animation_player: AnimationPlayer = %transitionAnimationPlayer

func play_transition(transition_name:String)->void:
	if transition_animation_player != null:
		if not transition_animation_player.get_animation_list().has(transition_name):
			print_debug("The transition animation does not exist")
			return
			
	var transition_duration = transition_animation_player.get_animation(transition_name).length
	get_tree().create_timer(transition_duration).timeout.connect(animation_timeout.bind(transition_name))
	transition_animation_player.play(transition_name)
	await transition_animation_player.animation_finished
	return


func animation_timeout(anim_name:String):
	if transition_animation_player.current_animation != anim_name:
		return
		
	print_debug("timeout: Stopped waiting for animation " + anim_name)
	transition_animation_player.animation_finished.emit()
