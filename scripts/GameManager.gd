extends Node


var score := 0

signal score_changed(new_score)


func add_score(amount: int):
	score += amount
	score_changed.emit(score)


func reset_score():
	score = 0
	score_changed.emit(score)
