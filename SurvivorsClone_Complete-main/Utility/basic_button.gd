extends Button

# Define the custom signal (without parentheses, as per Godot 4 convention)
signal click_end

func _on_mouse_entered():
	$snd_hover.play()
	
func _on_pressed():
	$snd_click.play()
	emit_signal("click_end")

# Remove unnecessary _on_click_end() method since it's not used
# Remove _on_snd_click_finished() since we no longer wait for the audio to finish


func _on_btn_play3_click_end() -> void:
	pass # Replace with function body.
