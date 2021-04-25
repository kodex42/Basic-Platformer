extends Control

func _on_Player_num_coins_changed(amount, _diff):
	$Label.text = str(amount)
