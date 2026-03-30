extends "../scripts/UIPanel.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UIManager.instance.register_event(NoteType.player_main_text,_ontext)
	UIManager.instance.register_event(NoteType.player_main_interactive,_oninteractive)
	UIManager.instance.register_event(NoteType.player_main_cross,_oncross)
	UIManager.instance.register_event(NoteType.player_main_money_change,_onmoney_change)

func initialize(data: Dictionary) -> void:
	$HBoxContainer/Container2/money.text = str(GameManager.instance.player_data.gold)

func _onmoney_change(event_name: String) -> void:
	$HBoxContainer/Container2/money.text = str(GameManager.instance.player_data.gold)

func _ontext(event_name: String,show:bool, interactive_text:String = "") -> void:
	$label_text.text = interactive_text
	$label_text.visible = show

func _oninteractive(event_name: String,show:bool) -> void:
	$interactive_main.visible = show

func _oncross(event_name: String, cross_index:int) -> void:
	$CenterContainer/Panel/Cross.visible = cross_index == 0
	$CenterContainer/Panel/Cross2.visible = cross_index == 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
