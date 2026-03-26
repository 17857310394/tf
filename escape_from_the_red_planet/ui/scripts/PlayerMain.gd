extends "../scripts/UIPanel.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UIManager.instance.register_event(NoteType.player_main_interactive,_oninteractive)
	UIManager.instance.register_event(NoteType.player_main_cross,_oncross)


func _oninteractive(event_name: String, interactive:bool) -> void:
	$interactive.visible = interactive

func _oncross(event_name: String, cross_index:int) -> void:
	$CenterContainer/Panel/Cross.visible = cross_index == 0
	$CenterContainer/Panel/Cross2.visible = cross_index == 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
