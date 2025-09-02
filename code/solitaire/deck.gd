@tool
extends Stack

@export var discard: Stack


func _ready():
	input_event.connect(_on_input_event)

func is_valid_card() -> bool:
	return false


func _on_input_event(camera, event, event_position, normal, shape_idx):
	if not event is InputEventMouse: return
	if Settings.PlayerHeldCard == null and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var debuga = discard.cards.duplicate()
			for c in debuga:
				c.is_in_stack = self
				cards.append(c)
				discard.cards.erase(c)
			shuffle()
	elif Settings.PlayerHeldCard == null: return
	
	if event is InputEventMouseMotion:
		Settings.PlayerHeldCard.global_position.x = event_position.x
		Settings.PlayerHeldCard.global_position.z = event_position.z
		Settings.PlayerHeldCard.global_position.y = high_card_in_stack.y + offset.y
		
	elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_valid_card():
		Settings.PlayerHeldCard.global_position = high_card_in_stack + offset
		if Settings.PlayerHeldCard.is_in_stack != null:
			Settings.PlayerHeldCard.is_in_stack.cards.erase(Settings.PlayerHeldCard)
			Settings.PlayerHeldCard.is_in_stack.resolve_moveable_cards()
		Settings.PlayerHeldCard.is_in_stack = self
		cards.append(Settings.PlayerHeldCard)
		resolve_moveable_cards()
		Settings.PlayerHeldCard.input_ray_pickable = true
		Settings.PlayerHeldCard = null
