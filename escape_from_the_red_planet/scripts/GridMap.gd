extends GridMap

# 引入常量库
const Constants = preload("res://scripts/constants.gd")

# 触发盒节点
var trigger_areas: Array[Area3D] = []

# 存储所有 TOWER_BASE 单元格的位置
var tower_base_cells: Array[Vector3i] = []

# 存储所有非空单元格数据
var all_cells: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_all_cells()
	# 存储所有 TOWER_BASE 单元格
	_store_tower_base_cells()
	# 为 MeshLibrary 中的 TOWER_BASE 元素添加 TowerBase 脚本
	_add_tower_base_for_mesh()

# 存储所有 TOWER_BASE 单元格
func _store_tower_base_cells() -> void:
	# 遍历所有单元格，存储 TOWER_BASE 单元格
	for pos in all_cells.keys():
		if all_cells[pos] == Constants.TOWER_BASE:
			tower_base_cells.append(pos)

# 获取所有非空单元格数据
func get_all_cells() -> void:
	var cells = {}
	
	# 定义一个合理的搜索范围
	var search_range = 64  # 搜索范围为 ±64
	
	# 遍历所有可能的单元格
	for x in range(-search_range, search_range):
		for y in range(-search_range, search_range):
			for z in range(-search_range, search_range):
				var pos = Vector3i(x, y, z)
				var item = get_cell_item(pos)
				if item != -1:  # 只添加非空单元格
					cells[pos] = item
	
	all_cells = cells

# 为 TOWER_BASE 网格元素添加 TowerBase 脚本
func _add_tower_base_for_mesh() -> void:
	# 加载 TowerBase 脚本
	var tower_base = preload("res://scenes/towers/TowerBase.tscn")
	
	# 遍历所有单元格，为 TOWER_BASE 元素添加 TowerBase 脚本
	for pos in tower_base_cells:
		# 计算单元格的世界坐标
		var cell_position = Vector3(pos.x, pos.y, pos.z)
		
		# 创建触发盒 Area3D 节点
		var tower_instance = tower_base.instantiate()
		tower_instance.name = "tower_" + str(pos.x) + "_" + str(pos.y) + "_" + str(pos.z)
		
		# 设置位置（在元素上方）
		tower_instance.position = Vector3(pos.x, pos.y, pos.z) * cell_size + Vector3(0, 2, 0)
		
		# 添加到场景
		add_child(tower_instance)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
