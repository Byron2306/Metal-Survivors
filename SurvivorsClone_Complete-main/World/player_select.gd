extends Control

func _ready():
	pass

func _on_btn_axel_click_end():
	Global.selected_character = "res://Textures/Player/axel_sprite.png"
	get_tree().change_scene_to_file("res://World/stage_select.tscn")

func _on_btn_lucias_click_end():
	Global.selected_character = "res://Textures/Player/lucias_sprite.png"
	get_tree().change_scene_to_file("res://World/stage_select.tscn")

func _on_btn_brutus_click_end():
	Global.selected_character = "res://Textures/Player/brutus_sprite.png"
	get_tree().change_scene_to_file("res://World/stage_select.tscn")

func _on_btn_aiden_click_end():
	Global.selected_character = "res://Textures/Player/aiden_sprite.png"
	get_tree().change_scene_to_file("res://World/stage_select.tscn")

func _on_btn_doug_click_end():
	Global.selected_character = "res://Textures/Player/doug_sprite.png"
	get_tree().change_scene_to_file("res://World/stage_select.tscn")

func _on_btn_jesse_click_end():
	Global.selected_character = "res://Textures/Player/jesse_sprite.png"
	get_tree().change_scene_to_file("res://World/stage_select.tscn")

func _on_btn_malcolm_click_end():
	Global.selected_character = "res://Textures/Player/malcolm_sprite.png"
	get_tree().change_scene_to_file("res://World/stage_select.tscn")

func _on_btn_xavier_click_end():
	Global.selected_character = "res://Textures/Player/xavier_sprite.png"
	get_tree().change_scene_to_file("res://World/stage_select.tscn")

func _on_btn_stryker_click_end():
	Global.selected_character = "res://Textures/Player/stryker_sprite.png"
	get_tree().change_scene_to_file("res://World/stage_select.tscn")

func _on_btn_kyle_click_end():
	Global.selected_character = "res://Textures/Player/kyle_sprite.png"
	get_tree().change_scene_to_file("res://World/stage_select.tscn")

func _on_btn_back_click_end():
	get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")
