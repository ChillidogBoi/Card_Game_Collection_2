extends Stack


@export var deck: Stack

func is_valid_card() -> bool:
	if Settings.PlayerHeldCard.is_in_stack == deck: return true
	else: return false
