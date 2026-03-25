# TowerRegistry.gd
# 防御塔注册机制
# 单例类，用于管理所有防御塔类型的注册和创建

class_name TowerRegistry

# 引用TowerData类
const TowerData = preload("res://scripts/towers/TowerData.gd")
# 引用BaseTower类
const BaseTower = preload("res://scripts/towers/BaseTower.gd")

var tower_types = {}  # 防御塔类型字典，键为类型名称，值为包含脚本和数据的字典

# 注册防御塔类型
# 功能：注册新的防御塔类型
# 参数：
#   type_name: 防御塔类型名称
#   tower_script: 防御塔脚本
#   tower_data: 防御塔数据
func register_tower_type(type_name: String, tower_script: Script, tower_data: TowerData) -> void:
    tower_types[type_name] = {
        "script": tower_script,
        "data": tower_data
    }

# 获取防御塔类型
# 功能：根据类型名称获取防御塔类型信息
# 参数：
#   type_name: 防御塔类型名称
# 返回值：
#   Dictionary: 防御塔类型信息，包含script和data
func get_tower_type(type_name: String) -> Dictionary:
    return tower_types.get(type_name, null)

# 获取所有防御塔类型
# 功能：获取所有已注册的防御塔类型名称
# 返回值：
#   Array: 防御塔类型名称列表
func get_all_tower_types() -> Array:
    return tower_types.keys()

# 创建防御塔实例
# 功能：根据类型名称创建防御塔实例
# 参数：
#   type_name: 防御塔类型名称
#   position: 防御塔位置
# 返回值：
#   BaseTower: 防御塔实例
func create_tower(type_name: String, position: Vector3) -> BaseTower:
    var tower_info = get_tower_type(type_name)
    if not tower_info:
        return null
    
    var tower = tower_info.script.new()
    tower.tower_data = tower_info.data
    tower.position = position
    return tower

# 初始化
# 功能：初始化防御塔注册器，注册默认防御塔类型
func _ready():
    # 这里可以注册默认的防御塔类型
    # 例如：
    # var ground_tower_script = preload("res://scripts/GroundAttackTower.gd")
    # var ground_tower_data = preload("res://data/ground_tower.tres")
    # register_tower_type("ground", ground_tower_script, ground_tower_data)
    pass
