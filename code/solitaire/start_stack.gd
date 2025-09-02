@tool
extends Stack

var suit: int = -1
var cur_val: int = 0


func _ready():
	high_card_in_stack = global_position
	gen()
	input_event.connect(_on_input_event)
	allow_carried_cards = true

func is_valid_card() -> bool:
	if cards.size() != 0:
		if Settings.PlayerHeldCard.Value != cur_val - 1: return false
		if posmod(Settings.PlayerHeldCard.Suit, 2) == posmod(suit, 2): return false
	
	suit = Settings.PlayerHeldCard.Suit
	cur_val = Settings.PlayerHeldCard.Value
	
	return true

func resolve_valid_cards():
	if cards.size() == 0: return
	
	suit = cards.back().Suit
	cur_val = cards.back().Value
	
	var reverse_off: int = 1
	for c in cards:
		if c.Flipped:
			reverse_off += 1
			c.global_position.x = global_position.x
			c.global_position.z = global_position.z
	for c in cards:
		if not c.Flipped:
			c.global_position.z -= reverse_off * offset.z
			c.global_position.x -= reverse_off * offset.x
	cards.back().Moveable = true
