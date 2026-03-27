class_name UIPanel extends Control

# UI面板基类
# 所有UI面板的父类，提供通用方法和属性

# 初始化
# 参数:
#   data: 初始化数据
func initialize(data: Dictionary) -> void:
	# 子类实现
	pass

# 显示动画
func show_animation() -> void:
	# 默认淡入效果
	modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.5)

# 隐藏动画
func hide_animation() -> void:
	# 默认淡出效果
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)

# 更新数据
# 参数:
#   data: 更新数据
func update_data(data: Dictionary) -> void:
	# 子类实现
	pass

# 显示面板
func show_panel() -> void:
	visible = true
	show_animation()

# 隐藏面板
func hide_panel() -> void:
	hide_animation()
	# 动画完成后设置visible为false
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(func():
		visible = false
	)

# 获取UIManager实例
func get_ui_manager() -> UIManager:
	return UIManager.instance

func dispose() -> void:
	pass
