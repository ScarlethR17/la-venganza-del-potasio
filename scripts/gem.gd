extends Area2D


func _on_body_entered(body):
	GameManager.add_score(6)
	queue_free()
