# gold_counter_ui.gd
extends HBoxContainer

@onready var gold_icon: TextureRect = $GoldIcon
@onready var gold_label: Label = $GoldLabel

func _ready() -> void:
	# Connect to global gold signal
	Global.gold_changed.connect(_on_gold_changed)
	
	# Initialize display
	_update_display(Global.gold)

func _on_gold_changed(new_amount: int) -> void:
	_update_display(new_amount)
	# Animate the change
	_animate_gold_change()

func _update_display(amount: int) -> void:
	if gold_label:
		gold_label.text = str(amount)

func _animate_gold_change() -> void:
	# Pulse effect when gold changes
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2.ONE, 0.1)
	
	# Flash gold color
	if gold_label:
		var original_color = gold_label.modulate
		gold_label.modulate = Color.YELLOW
		tween.tween_property(gold_label, "modulate", original_color, 0.2)
