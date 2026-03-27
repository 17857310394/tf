class_name PanelManager extends Node

# 面板缓存
var panels: Dictionary = {}

# 资源管理器实例
var resource_manager: UIResource

# 初始化
func _ready() -> void:
	# 获取资源管理器实例
	var ui_manager = get_parent()
	if ui_manager and ui_manager is UIManager:
		resource_manager = ui_manager.resource_manager

# 创建面板实例
# 参数:
#   panel_name: 面板名称
#   data: 初始化数据
# 返回: 面板实例
func create_panel_instance(panel_name: String, data: Dictionary) -> Node:
	# 加载面板预制体
	var prefab = resource_manager.load_panel_prefab(panel_name)
	if not prefab:
		return null
	
	# 实例化面板
	var panel = prefab.instantiate()
	if not panel:
		return null
	
	# 设置面板名称
	panel.name = panel_name
	
	# 初始化面板数据
	if panel.has_method("initialize"):
		panel.initialize(data)
	
	# 隐藏面板
	panel.hide()
	
	return panel

# 显示面板
# 参数:
#   panel: 面板实例
#   data: 显示数据
func show_panel(panel: Node, data: Dictionary) -> void:
	if not panel:
		return
	
	# 显示面板
	if panel.has_method("show_panel"):
		panel.show_panel()
	else:
		panel.show()
	
	# 执行显示动画
	if panel.has_method("show_animation"):
		panel.show_animation()
	
	# 更新面板数据
	if panel.has_method("update_data"):
		panel.update_data(data)

# 隐藏面板
# 参数:
#   panel: 面板实例
#   destroy: 是否销毁面板
func hide_panel(panel: Node, destroy: bool) -> void:
	if not panel:
		return
	
	# 执行隐藏动画
	if panel.has_method("hide_panel"):
		panel.hide_panel()
	elif panel.has_method("hide_animation"):
		panel.hide_animation()
	else:
		panel.hide()
	
	# 销毁面板
	if destroy:
		# 延迟销毁，确保动画完成
		if panel.has_method("dispose"):
			panel.dispose()
		panel.call_deferred("queue_free")

# 销毁面板
# 参数:
#   panel: 面板实例
func destroy_panel(panel: Node) -> void:
	if not panel:
		return
	
	panel.queue_free()

# 设置面板层级
# 参数:
#   panel: 面板实例
#   z_index: 层级值
func set_panel_z_index(panel: Node, z_index: int) -> void:
	if not panel:
		return
	
	# 查找CanvasLayer父节点
	var canvas_layer = panel.get_parent()
	while canvas_layer and not canvas_layer is CanvasLayer:
		canvas_layer = canvas_layer.get_parent()
	
	if canvas_layer and canvas_layer is CanvasLayer:
		canvas_layer.z_index = z_index
