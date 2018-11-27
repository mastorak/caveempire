extends AnimatedSprite

func draw_and_animate_human(action, velocity, selected):
	#selected animation and play
	if action==get_owner().ACTION.IDLE:
		play("idle")
	elif action==get_owner().ACTION.MOVE && velocity.x>0:
		flip_h=false
		play("walking")
	elif action==get_owner().ACTION.MOVE && velocity.x<0:
		flip_h=true
		play("walking")
	
	# draw or hide selected frame
	if selected:
		$SelectedFrame.visible=true
	else:
		$SelectedFrame.visible=false		
