@tool
class_name Card
extends StaticBody3D

const CARD = preload("res://assets/card.obj")
const CARD_MATERIAL = preload("res://assets/card.material")
const CARD_COLOR = preload("res://assets/card_color.res")
const YOSTER = preload("res://assets/yoster.ttf")


@export_multiline var CardText: String
@export_enum("Center", "One Corner", "Two Corners", "Four Corners") var TextStyle = 2
@export var FontColor: Color = Color(0,0,0)
@export var Moveable: bool = true
@export var Flipped: bool = false
@export_tool_button("generate") var create_card = gen

@export_category("Design")
@export var CardColor: Color = Color(1,1,1)
@export var Symbol: CompressedTexture2D:
	set(v):
		Symbol = v
		TextSymbolOffset = Vector2(
			((Symbol.get_size().x/2) * PixelSize), (((Symbol.get_size().y/2) + FontSize) * -PixelSize)
		)
@export var SymbolUnderText: bool = true
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var TextSymbolOffset: Vector2 = Vector2(0.0,-0.12)
@export var Amount: int = 0
@export var Lines: int = 1

@export_group("Advanced")#category("Advanced")
@export var FaceArt: CompressedTexture2D = null
@export var Suit: int
@export var Value: int
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var FieldSize: Vector2 = Vector2(0.35, 0.6)
@export_custom(PROPERTY_HINT_NONE, "suffix:m²") var PixelSize: float = 0.01
@export var _Font: Font = YOSTER
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var FontSize: int = 12
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var FontOutlineSize: int = 0
@export var FontOutlineColor: Color = Color(0,0,0)
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var LineSpacing: int = -18
@export_custom(PROPERTY_HINT_NONE, "suffix:px") var TextMaxWidth: int = 128

var start_position: Vector3
var is_in_stack: Stack = null


func _ready():
	gen()
	input_event.connect(_on_input_event)
	Settings.AllCards.append(self)


func gen():
	for c in get_children(true):
		remove_child(c)
	
	#paper
	var body = MeshInstance3D.new()
	add_child(body)
	body.mesh = CARD
	body.set_surface_override_material(0,CARD_MATERIAL)
	body.create_convex_collision()
	get_child(0).get_child(0).get_child(0).reparent(self)
	get_child(0).get_child(0).queue_free()
	
	#color
	if CardColor != Color(1,1,1):
		var color = MeshInstance3D.new()
		add_child(color)
		color.position = Vector3(0,0.007,0)
		color.mesh = CARD_COLOR
		var color_material = StandardMaterial3D.new()
		color_material.albedo_color = CardColor
		color.set_surface_override_material(0, color_material)
	
	
	parse_text()
	
	parse_symbols_gpt()
	
	parse_art()
	
	if Flipped: rotation.z = PI
	else: rotation.z = 0

func parse_text():
	var text = new_label()
	add_child(text)
	
	if [1,2,3].has(TextStyle):
		text.position = Vector3(-0.325, 0.008, -0.49)
		text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		text.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	if [2,3].has(TextStyle):
		var text2 = text.duplicate()
		add_child(text2)
		text2.rotate_y(PI)
		text2.position = Vector3(0.325, 0.008, 0.49)
	if [3].has(TextStyle):
		text = text.duplicate()
		add_child(text)
		text.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		text.position = Vector3(0.325, 0.008, -0.49)
		var text2 = text.duplicate()
		add_child(text2)
		text2.rotate_y(PI)
		text2.position = Vector3(-0.325, 0.008, 0.49)

func new_label() -> Label3D:
	var text = Label3D.new()
	text.font = _Font
	text.position = Vector3(0,0.008,0)
	text.rotate_x(-PI/2)
	text.modulate = FontColor
	text.outline_size = FontOutlineSize
	text.outline_modulate = FontOutlineColor
	text.pixel_size = PixelSize
	text.font_size = FontSize
	text.line_spacing = LineSpacing
	text.shaded = true
	text.double_sided = false
	text.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	text.width = TextMaxWidth
	text.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	text.text = CardText
	
	if SymbolUnderText:
		var symb = new_sprite()
		text.add_child(symb)
		symb.position = Vector3(TextSymbolOffset.x, TextSymbolOffset.y, 0)
		symb.rotate_x(PI/2)
#		print(symb.position)
	
	return text

func new_sprite() -> Sprite3D:
	var symb = Sprite3D.new()
	symb.texture = Symbol
	symb.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	symb.shaded = true
	symb.double_sided = false
	symb.position = Vector3(0,0.008,0)
	symb.axis = 1
	symb.pixel_size = PixelSize
	
	return symb

func parse_symbols_gpt():
	if not Symbol or not Amount or not Lines: return
	
	var symb = new_sprite()
	
	var count: int = 0
	for n in get_sym_positions():
		symb = symb.duplicate()
		add_child(symb)
		symb.position = Vector3(n.x, 0.008, n.z)

func get_sym_positions() -> Array:
	var positions: Array = []
	if Amount <= 0 or Lines <= 0:
		return positions
	
	# Step 1: Base distribution
	var base_per_row: int = Amount / Lines
	var remainder: int = Amount % Lines
	
	var row_lengths: Array = []
	for i in range(Lines):
		row_lengths.append(base_per_row)
	
	# Step 2: Symmetric distribution of remainder
	var top = 0
	var bottom = Lines - 1
	while remainder >= 2 and top < bottom:
		row_lengths[top] += 1
		row_lengths[bottom] += 1
		remainder -= 2
		top += 1
		bottom -= 1
	
	# If exactly one remainder left, assign it to the middle row
	if remainder == 1 and Lines % 2 == 1:
		var mid = Lines / 2
		row_lengths[mid] += 1
		remainder = 0
	
	# Step 3: Compute spacing
	var max_row_len = 0
	for row_len in row_lengths:
		if row_len > max_row_len:
			max_row_len = row_len
	
	var x_spacing = 0.0
	if max_row_len > 1:
		x_spacing = FieldSize.x / (max_row_len - 1)
	
	var z_spacing = 0.0
	if Lines > 1:
		z_spacing = FieldSize.y / (Lines - 1)
	
	# Step 4: Generate positions row by row
	var y_offset = (Lines - 1) / 2.0
	for r in range(Lines):
		var row_len: int = row_lengths[r]
		if row_len == 0:
			continue
		
		var x_offset = (row_len - 1) / 2.0
		for c in range(row_len):
			var x = (c - x_offset) * x_spacing
			var z = (r - y_offset) * z_spacing
			positions.append(Vector3(x, 0, z))
	
	return positions

func parse_art():
	if not FaceArt: return
	var art = new_sprite()
	add_child(art)
	art.texture = FaceArt


func _on_input_event(camera, event, event_position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if Moveable and event.button_index == MOUSE_BUTTON_LEFT and Settings.PlayerHeldCard == null:
			if abs(abs(rotation.z) - PI) < 0.001:
				for n:int in 9:
					rotate_z(deg_to_rad(20))
					await get_tree().create_timer(0).timeout
				Flipped = false
			else:
				start_position = position
				Settings.PlayerHeldCard = self
				input_ray_pickable = false
				if is_in_stack != null:
					if is_in_stack.cards.find(self) != is_in_stack.cards.size():
						Settings.CarriedCards = []
						for n in range(is_in_stack.cards.find(self) + 1, is_in_stack.cards.size()):
							Settings.CarriedCards.append(is_in_stack.cards[n])
				
		elif event.button_index == MOUSE_BUTTON_LEFT and Settings.PlayerHeldCard != null:
			if is_in_stack != null:
				is_in_stack._on_input_event(camera, event, event_position, normal, shape_idx)
			else:
				Settings.PlayerHeldCard.global_position = Settings.PlayerHeldCard.start_position
				Settings.PlayerHeldCard.input_ray_pickable = true
				Settings.PlayerHeldCard = null
	
	elif event is InputEventMouseMotion and Settings.PlayerHeldCard != null:
		Settings.PlayerHeldCard.global_position.x = event_position.x
		Settings.PlayerHeldCard.global_position.z = event_position.z
		Settings.PlayerHeldCard.global_position.y = Settings.HighestCard + 0.01
