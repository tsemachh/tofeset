extends Control

func set_result(winner: String, p1_score: int, p2_score: int) -> void:
	$WinnerLabel.text = "%s wins the match!" % winner
	$ScoreLabel.text = "Final Score — P1: %d  P2: %d" % [p1_score, p2_score]
	$PromptLabel.text = "SPACE/Enter: Play Again     Esc: Quit"
