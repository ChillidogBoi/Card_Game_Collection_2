@tool
extends Stack

var suit: int = -1
var cur_val: int = 0


func is_valid_card() -> bool:
	if Settings.PlayerHeldCard.Value != cur_val + 1: return false
	
	if suit == -1: suit = Settings.PlayerHeldCard.Suit
	elif Settings.PlayerHeldCard.Suit != suit: return false
	
	cur_val += 1
	
	if cur_val == 13:
		Settings.WinFlags += 1
		if Settings.WinFlags == 4: Settings.game_won.emit()
	
	return true


func resolve_valid_cards():
	if cards.size() == 0:
		suit = -1
		cur_val = 0
	
	else: cur_val = cards.back().Value
