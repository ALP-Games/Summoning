class_name UI extends Control

@export var player: Player

@export var selected_count_label: Label = null
@export var selection_info_label: Label = null
@export var necomancer_health_label: Label = null
@export var spirit_well_health_label: Label = null
@export var blue_soul_amount: Label = null
@export var red_soul_amount: Label = null

var selection_info_singular := "Minion selected"
var selection_info_plural := "Minions selected"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selected_count_label.text = "0x"
	selection_info_label.text = selection_info_plural


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player == null:
		game_manager.gameplay.load_game_over()
		return
		
	var amount := player.minions_selected.size()
	selected_count_label.text = str(amount) + "x"
	if amount == 1:
		selection_info_label.text = selection_info_singular
	else:
		selection_info_label.text = selection_info_plural
	
	var hp = player.health_component.current_hp
	if hp < 0:
		necomancer_health_label.text = str(0)
	else:
		necomancer_health_label.text = str(hp)
	
	
	if game_manager.gameplay.spirit_well == null:
		game_manager.gameplay.load_game_over()
		return
	var well_hp = game_manager.gameplay.spirit_well.health_component.current_hp
	if well_hp < 0:
		spirit_well_health_label.text = str(0)
	else:
		spirit_well_health_label.text = str(well_hp)
	
	blue_soul_amount.text = str(player.resources.blue_souls_amount)
	red_soul_amount.text = str(player.resources.red_souls_amount)
	
