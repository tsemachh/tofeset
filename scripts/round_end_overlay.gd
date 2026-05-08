extends Control

func set_result(winner: String, cause: StringName) -> void:
	var cause_text := ""
	match cause:
		&"caught":
			cause_text = "Caught!"
		&"out_of_bounds":
			cause_text = "Out of bounds!"
		&"hit_trail":
			cause_text = "Hit a trail!"
		_:
			cause_text = str(cause)
	$WinnerLabel.text = "%s wins!" % winner
	$CauseLabel.text = cause_text
