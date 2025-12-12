extends Control

var player_select = "res://World/player_select.tscn"

func _on_btn_play_click_end():
	var _level = get_tree().change_scene_to_file(player_select)

func _on_btn_exit_click_end():
	get_tree().quit()
