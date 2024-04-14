class_name Player extends Character

@export var speed: float = 10.0
@export var selection: PackedScene = null
@export var model: Node3D = null
@export var resources: PlayerResources = null

@onready var camera: Camera3D = $Camera3D
@onready var follow_node: FollowNode = $FollowNode

var anim_player: AnimationPlayer = null
@onready var x_scale: float = model.scale.x

var minions_selected: Array[Minion] = []
var click_selection: Minion = null

var selection_instantiated: bool = false
var mouse_held: bool = false
var world_click_pos: Vector3
var selection_radius: Area3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init()
	for child in model.get_children():
		if child is AnimationPlayer:
			anim_player = child


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_proccess_left_mouse_button(mouse_event)
	if event is InputEventMouseMotion:
		_process_mouse_motion(event)


func _process_mouse_motion(motion_event: InputEventMouseMotion) -> void:
	if mouse_held:
		var world_click := _process_world_click(1)
		if not selection_instantiated and \
		world_click.size() > 0 and world_click.position != world_click_pos:
			selection_instantiated = true
			selection_radius = selection.instantiate()
			add_child(selection_radius)
			selection_radius.global_position = world_click_pos
		
		if world_click.size() > 0 and selection_instantiated:
			var length := (Vector3(world_click.position) - world_click_pos).length() * 2
			selection_radius.scale = Vector3(length, length, length)


func _proccess_left_mouse_button(mouse_event: InputEventMouseButton) -> void:
	if mouse_event.pressed:
		mouse_held = true
		var intersection := _process_world_click()
		if intersection.size() > 0 and intersection.collider is Minion:
			click_selection = intersection.collider
		var world_click := _process_world_click(1)
		if world_click.size() > 0:
			world_click_pos = world_click.position
	elif not mouse_event.pressed:
		mouse_held = false
		set_minions_selection_off()
		minions_selected = []
		if selection_instantiated:
			var bodies := selection_radius.get_overlapping_bodies()
			for body in bodies:
				if body is Minion:
					minions_selected.append(body)
			selection_instantiated = false
			selection_radius.queue_free()
		else:
			var intersection := _process_world_click()
			# if we havent started drawing a box
			if intersection.size() > 0 and intersection.collider == click_selection:
				minions_selected = [intersection.collider]
		set_minions_selection_on()
		click_selection = null


func _process_world_click(collision_mask: int = 0xFFFFFFFF) -> Dictionary:
	var space_state := get_world_3d().direct_space_state
	var mouse_position := get_viewport().get_mouse_position()
	var rayOrigin := camera.project_ray_origin(mouse_position)
	var rayEnd := rayOrigin + camera.project_ray_normal(mouse_position) * 1000
	return space_state.intersect_ray(\
		PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd, collision_mask))


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var movement_velocity := Vector3(input_dir.x, 0, input_dir.y) * speed
	linear_velocity = movement_velocity
	
	var dir := sign(input_dir.x) as int
	if dir:
		model.scale.x = x_scale * dir
	if movement_velocity.length() > 0:
		anim_player.play("Walk")
	else:
		anim_player.pause()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("follow"):
		for minion in minions_selected:
			follow_node.add_new_folower(minion)
	if Input.is_action_just_pressed("stay"):
		for minion in minions_selected:
			follow_node.remove_follower(minion)


func set_minions_selection_on() -> void:
	for minion in minions_selected:
		follow_node.set_selection_visible(minion, true)


func set_minions_selection_off() -> void:
	for minion in minions_selected:
		follow_node.set_selection_visible(minion, false)
