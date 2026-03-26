class_name UIResource extends Node

# 资源缓存
var resource_cache: Dictionary = {}

# 面板路径映射
var panel_paths: Dictionary = {
	"PlayerMain": "res://ui/panels/PlayerMain.tscn",
	"Settings": "res://ui/panels/Settings.tscn",
}

# 加载面板预制体
# 参数:
#   panel_name: 面板名称
# 返回: PackedScene或null
func load_panel_prefab(panel_name: String) -> PackedScene:
	# 检查缓存
	if resource_cache.has(panel_name):
		return resource_cache[panel_name]
	
	# 获取面板路径
	var path = panel_paths.get(panel_name)
	if not path:
		# 尝试默认路径
		path = "res://ui/panels/" + panel_name + ".tscn"
	
	# 加载资源
	var prefab = load(path)
	if not prefab:
		print("Error: Failed to load panel prefab: " + path)
		return null
	
	# 缓存资源
	resource_cache[panel_name] = prefab
	
	return prefab

# 预加载资源
# 参数:
#   resources: 资源路径数组
func preload_resources(resources: Array) -> void:
	for resource_path in resources:
		if not resource_cache.has(resource_path):
			var resource = load(resource_path)
			if resource:
				resource_cache[resource_path] = resource

# 释放资源
# 参数:
#   resource_path: 资源路径
func release_resource(resource_path: String) -> void:
	if resource_cache.has(resource_path):
		resource_cache.erase(resource_path)

# 清理缓存
func clear_cache() -> void:
	resource_cache.clear()

# 添加面板路径映射
# 参数:
#   panel_name: 面板名称
#   path: 面板路径
func add_panel_path(panel_name: String, path: String) -> void:
	panel_paths[panel_name] = path
