extends Area2D


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	call_deferred("_go_to_menu")


func _go_to_menu():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
