@tool
class_name Stack
extends StaticBody3D


const CARD = preload("res://assets/card.obj")
@export var color: Color = Color(0.0,0.75,1.0,0.35)
@export var cards: Array[Card] = []
@export var offset: Vector3 = Vector3(0, 0.01, 0)
@export_enum("None", "Top Only", "Face Up", "All") var moveable_cards = 0
@export_tool_button("Generate") var generate_new_table = gen
var high_card_in_stack: Vector3



func _ready():
	high_card_in_stack = global_position
	gen()
	input_event.connect(_on_input_event)


func gen():
	for c in get_children(true):
		remove_child(c)
	
	resolve_moveable_cards()
	
	var body = MeshInstance3D.new()
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	add_child(body)
	body.mesh = CARD
	body.set_surface_override_material(0,material)
	body.create_convex_collision()
	get_child(0).get_child(0).get_child(0).reparent(self)
	get_child(0).get_child(0).queue_free()
	
	await get_tree().create_timer(0.1).timeout
	var ray = RayCast3D.new()
	add_child(ray)
	ray.target_position = Vector3(0,-10,0)
	
	print(ray.target_position)


func _on_input_event(camera, event, event_position, normal, shape_idx):
	if Settings.PlayerHeldCard == null or not event is InputEventMouse: return
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

func shuffle():
	for n:int in 8:
		cards.shuffle()
	resolve_moveable_cards()

func resolve_moveable_cards():
	for c in cards:
		c.Moveable = true
	if moveable_cards == 0:
		for c in cards:
			c.Moveable = false
	elif moveable_cards == 1:
		var im_cards = cards.duplicate()
		im_cards.pop_back()
		for c in im_cards:
			c.Moveable = false
	elif moveable_cards == 2:
		for c in cards:
			if abs(abs(c.rotation.z) - PI) < 0.001:
				c.Moveable = false
	
	high_card_in_stack = global_position
	for n in cards:
		n.global_position = high_card_in_stack + offset
		n.is_in_stack = self
		high_card_in_stack += offset


func is_valid_card() -> bool:
	return true
