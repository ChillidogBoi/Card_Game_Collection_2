@tool
class_name Table
extends StaticBody3D

@export var table_size: Vector3 = Vector3(10,1,10)
@export var table_color: Color = Color(0.0, 0.314, 0.082)
@export_tool_button("Generate") var generate_new_table = gen
var pointer: MeshInstance3D


func gen():
	for c in get_children(true):
		remove_child(c)
	
	var body = MeshInstance3D.new()
	add_child(body)
	var mesh = BoxMesh.new()
	mesh.size = table_size
	body.mesh = mesh
	mesh = StandardMaterial3D.new()
	mesh.albedo_color = table_color
	body.set_surface_override_material(0,mesh)
	body.create_convex_collision()
	get_child(0).get_child(0).get_child(0).reparent(self)
	get_child(0).get_child(0).queue_free()

func _ready():
	gen()
	input_event.connect(_on_input_event)

func _on_input_event(camera, event, event_position, normal, shape_idx):
	if Settings.PlayerHeldCard == null or not event is InputEventMouse: return
	
	if event is InputEventMouseMotion:
		Settings.PlayerHeldCard.global_position.x = event_position.x
		Settings.PlayerHeldCard.global_position.z = event_position.z
		Settings.PlayerHeldCard.global_position.y = Settings.HighestCard + 0.01
		
	elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Settings.PlayerHeldCard.global_position = Settings.PlayerHeldCard.start_position
		Settings.PlayerHeldCard.input_ray_pickable = true
		Settings.PlayerHeldCard = null

func _process(delta):
	await ready
	if Settings.PlayerHeldCard == null and pointer != null:
		pointer = null
