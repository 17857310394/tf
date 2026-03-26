extends "../scripts/UIPanel.gd"

# 初始化
func initialize(data: Dictionary) -> void:
	# 连接按钮信号
	$VBoxContainer/HBoxContainer/StartButton.pressed.connect(_on_start_button_pressed)
	$VBoxContainer/HBoxContainer/SettingsButton.pressed.connect(_on_settings_button_pressed)
	$VBoxContainer/HBoxContainer/ExitButton.pressed.connect(_on_exit_button_pressed)

# 显示动画
func show_animation() -> void:
	# 淡入效果
	modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)

# 隐藏动画
func hide_animation() -> void:
	# 淡出效果
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)

# 更新数据
func update_data(data: Dictionary) -> void:
	# 可以根据需要更新菜单数据
	pass

# 开始游戏按钮点击
func _on_start_button_pressed() -> void:
	# 隐藏主菜单
	UIManager.instance.hide_panel("MainMenu")
	# 触发开始游戏事件
	UIManager.instance.emit_event("game_start")

# 设置按钮点击
func _on_settings_button_pressed() -> void:
	# 显示设置面板
	UIManager.instance.show_panel("Settings")

# 退出按钮点击
func _on_exit_button_pressed() -> void:
	# 退出游戏
	get_tree().quit()
