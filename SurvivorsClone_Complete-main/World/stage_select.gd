extends Control

var level1 = "res://World/world.tscn"
var level2 = "res://World/level2.tscn"
var level3 = "res://World/level3.tscn"
var level4 = "res://World/level5.tscn"
var level5 = "res://World/level4.tscn"
var level6 = "res://World/level6.tscn"
var level7 = "res://World/level7.tscn"
var level8 = "res://World/level8.tscn"
var level9 = "res://World/level9.tscn"
var level10 = "res://World/level10.tscn"

func _on_btn_play1_click_end():
	print("Loading Stage 1")
	var error = get_tree().change_scene_to_file(level2)
	if error != OK:
		print("Failed to load Stage 1: ", error)

func _on_btn_play2_click_end():
	print("Loading Stage 2")
	var error = get_tree().change_scene_to_file(level1)
	if error != OK:
		print("Failed to load Stage 2: ", error)

func _on_btn_play3_click_end():
	print("Loading Stage 3")
	var error = get_tree().change_scene_to_file(level3)
	if error != OK:
		print("Failed to load Stage 3: ", error)

func _on_btn_play4_click_end():
	print("Loading Stage 4")
	var error = get_tree().change_scene_to_file(level4)
	if error != OK:
		print("Failed to load Stage 4: ", error)

func _on_btn_play5_click_end():
	print("Loading Stage 5: Doom Metal")
	var error = get_tree().change_scene_to_file(level5)
	if error != OK:
		print("Failed to load Stage 5: ", error)

func _on_btn_play6_click_end():
	print("Loading Stage 6: Glam Metal")
	var error = get_tree().change_scene_to_file(level6)
	if error != OK:
		print("Failed to load Stage 6: ", error)

func _on_btn_play7_click_end():
	print("Loading Stage 7: Folk Metal")
	var error = get_tree().change_scene_to_file(level7)
	if error != OK:
		print("Failed to load Stage 7: ", error)

func _on_btn_play8_click_end():
	print("Loading Stage 8: Prog Metal")
	var error = get_tree().change_scene_to_file(level8)
	if error != OK:
		print("Failed to load Stage 8: ", error)

func _on_btn_play9_click_end() -> void:
	print("Loading Stage 9: Industrial Metal")
	var error = get_tree().change_scene_to_file(level9)
	if error != OK:
		print("Failed to load Stage 8: ", error)

func _on_btn_exit_click_end():
	print("Exiting game")
	get_tree().quit()


func _on_btn_play_10_click_end() -> void:
	print("Loading Stage 10: Nu Metal")
	var error = get_tree().change_scene_to_file(level10)
	if error != OK:
		print("Failed to load Stage 8: ", error)
