extends "../scripts/UIPanel.gd"

# 初始化
func initialize(data: Dictionary) -> void:
	# 连接按钮信号
	$Panel/VBoxContainer/HBoxContainer/BackButton.pressed.connect(_on_back_button_pressed)
	# 连接滑块信号
	$Panel/VBoxContainer/HBoxContainer_2/HSlider.value_changed.connect(_on_volume_changed)
	# 连接复选框信号
	$Panel/VBoxContainer/HBoxContainer_3/CheckBox.toggled.connect(_on_fullscreen_toggled)

# 显示动画
func show_animation() -> void:
	# 淡入效果
	modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)

# 隐藏动画
func hide_animation() -> void:
	# 淡出效果
	modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)

# 更新数据
func update_data(data: Dictionary) -> void:
	# 更新音量
	if data.has("volume"):
		$Panel/VBoxContainer/HBoxContainer_2/HSlider.value = data["volume"]
	# 更新全屏状态
	if data.has("fullscreen"):
		$Panel/VBoxContainer/HBoxContainer_3/CheckBox.button_pressed = data["fullscreen"]

# 返回按钮点击
func _on_back_button_pressed() -> void:
	# 隐藏设置面板
	UIManager.instance.hide_panel("Settings")

# 音量变化
func _on_volume_changed(value: float) -> void:
	# 触发音量变化事件
	UIManager.instance.emit_event("volume_changed", {"volume": value})

# 全屏切换
func _on_fullscreen_toggled(button_pressed: bool) -> void:
	# 触发全屏变化事件
	UIManager.instance.emit_event("fullscreen_changed", {"fullscreen": button_pressed})
