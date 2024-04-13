class_name GruntSpawner extends Building

@export var spawn_interval: float = 5.0
@export var grunt: PackedScene = null
@export var spawn_offset: Vector3 = Vector3(0.0, 0.0, 3.0)

var elapsed_time: float = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time >= spawn_interval:
		elapsed_time -= spawn_interval
		var grunt_instance := grunt.instantiate() as Grunt
		grunt_instance.set_target(game_manager.gameplay.spirit_well)
		game_manager.gameplay.entities.add_child(grunt_instance)
		var spawn_pos := global_position
		spawn_pos.y = 0.0
		grunt_instance.global_position = spawn_pos + spawn_offset
		#grunt_instance.global_position += spawn_offset
	
