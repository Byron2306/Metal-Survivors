extends Node

var selected_character = "res://Textures/Player/axel.png" # Default to Axel
var gold: int = 0  # Player's gold/money

signal gold_changed(new_amount: int)

func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)

func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		gold_changed.emit(gold)
		return true
	return false
