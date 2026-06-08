extends CanvasLayer


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if get_tree().paused:
			resume()
		else:
			pause()


func resume():
	get_tree().paused = false
	visible = false


func pause():
	get_tree().paused = true
	visible = true


func _on_resume_pressed():
	resume()
