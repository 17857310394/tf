class_name UIManager extends Node

# 单例实例
static var instance: UIManager

# 模块实例
var panel_manager: PanelManager
var resource_manager: UIResource

# 面板缓存
var panels: Dictionary = {}

# 初始化
func _ready() -> void:
	instance = self
	
	# 初始化模块
	panel_manager = PanelManager.new()
	resource_manager = UIResource.new()
	
	add_child(panel_manager)
	add_child(resource_manager)

# 创建面板
# 参数:
#   panel_name: 面板名称
#   data: 初始化数据（可选）
#   parent: 父节点（可选，默认使用CanvasLayer）
# 返回: 面板实例
func create_panel(panel_name: String, data: Dictionary = {}, parent: Node = null) -> Node:
	# 检查面板是否已存在
	if panels.has(panel_name):
		return panels[panel_name]
	
	# 创建面板实例
	var panel = panel_manager.create_panel_instance(panel_name, data)
	if not panel:
		print("Error: Failed to create panel: " + panel_name)
		return null
	
	# 设置父节点
	if not parent:
		# 创建CanvasLayer作为默认父节点
		var canvas_layer = CanvasLayer.new()
		canvas_layer.name = "UILayer_" + panel_name
		add_child(canvas_layer)
		parent = canvas_layer
	
	parent.add_child(panel)
	panels[panel_name] = panel
	
	return panel

# 显示面板
# 参数:
#   panel_name: 面板名称
#   data: 显示数据（可选）
func show_panel(panel_name: String, data: Dictionary = {}) -> void:
	var panel = panels.get(panel_name)
	if not panel:
		# 面板不存在，创建面板
		panel = create_panel(panel_name, data)
		if not panel:
			return
	
	panel_manager.show_panel(panel, data)

# 隐藏面板
# 参数:
#   panel_name: 面板名称
#   destroy: 是否销毁面板（默认false）
func hide_panel(panel_name: String, destroy: bool = false) -> void:
	var panel = panels.get(panel_name)
	if not panel:
		return
	
	panel_manager.hide_panel(panel, destroy)
	
	if destroy:
		panels.erase(panel_name)

# 销毁面板
# 参数:
#   panel_name: 面板名称
func destroy_panel(panel_name: String) -> void:
	hide_panel(panel_name, true)

# 获取面板实例
# 参数:
#   panel_name: 面板名称
# 返回: 面板实例或null
func get_panel(panel_name: String) -> Node:
	return panels.get(panel_name, null)

# 检查面板是否存在
# 参数:
#   panel_name: 面板名称
# 返回: 是否存在
func has_panel(panel_name: String) -> bool:
	return panels.has(panel_name)

# 预加载面板资源
# 参数:
#   panel_names: 面板名称数组
func preload_panels(panel_names: Array) -> void:
	for panel_name in panel_names:
		resource_manager.load_panel_prefab(panel_name)

# 注册事件
# 参数:
#   event_name: 事件名称
#   callback: 回调函数
#   priority: 优先级
func register_event(event_name: String, callback: Callable, priority: int = 0) -> void:
	EventSystem.instance.on(event_name, callback, priority)

# 触发事件
# 参数:
#   event_name: 事件名称
#   data: 事件数据（可选）
func emit_event(event_name: String, data: Dictionary = {}) -> void:
	EventSystem.instance.emit(event_name, data)

# 注销事件
# 参数:
#   event_name: 事件名称
#   callback: 回调函数
func unregister_event(event_name: String, callback: Callable) -> void:
	EventSystem.instance.off(event_name, callback)

# 注册一次性事件
# 参数:
#   event_name: 事件名称
#   callback: 回调函数
#   priority: 优先级
func register_once_event(event_name: String, callback: Callable, priority: int = 0) -> void:
	EventSystem.instance.once(event_name, callback, priority)
