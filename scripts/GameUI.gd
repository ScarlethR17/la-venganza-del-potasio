extends CanvasLayer

var _last_health := -1


func _process(_delta):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		if player.health != _last_health:
			if _last_health != -1 and player.health < _last_health:
				$HealthLabel.modulate = Color.RED
				get_tree().create_timer(0.15).timeout.connect(_reset_health_color)
			_last_health = player.health
		$HealthLabel.text = "x" + str(player.health)
	$ScoreLabel.text = str(GameManager.score)


func _reset_health_color():
	$HealthLabel.modulate = Color.WHITE
