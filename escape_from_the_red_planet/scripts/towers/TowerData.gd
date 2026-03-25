# TowerData.gd
# 防御塔属性数据结构
# 用于存储防御塔的各种属性，包括基础属性、升级属性、视觉属性和特殊技能

class_name TowerData extends Resource

# 基础属性
@export var name: String = "Tower"  # 防御塔名称
@export var description: String = "A basic tower"  # 防御塔描述
@export var build_cost: int = 100  # 建造成本
@export var base_damage: float = 10.0  # 基础攻击力
@export var base_health: float = 100.0  # 基础生命值
@export var base_attack_speed: float = 1.0  # 攻击间隔（秒）
@export var base_range: float = 10.0  # 基础攻击范围
@export var attack_type: String = "ground"  # 攻击类型：ground（地面）、air（空中）、both（两者）

# 升级属性
@export var max_level: int = 3  # 最大升级等级
@export var damage_growth_rate: float = 1.5  # 攻击力成长率
@export var health_growth_rate: float = 1.3  # 生命值成长率
@export var attack_speed_growth_rate: float = 1.2  # 攻击速度成长率
@export var range_growth_rate: float = 1.1  # 攻击范围成长率
@export var upgrade_cost_base: int = 50  # 基础升级成本
@export var upgrade_cost_multiplier: float = 1.5  # 升级成本乘数

# 视觉属性
@export var scene_path: String = ""  # 防御塔场景路径
@export var icon_path: String = ""  # 防御塔图标路径

# 特殊技能
@export var skills: Array[Dictionary] = []  # 技能列表

# 获取升级成本
# 参数：
#   level: 当前等级
# 返回值：
#   int: 升级到下一级所需的成本
func get_upgrade_cost(level: int) -> int:
    if level >= max_level:
        return 0
    return int(upgrade_cost_base * pow(upgrade_cost_multiplier, level - 1))

# 验证数据
# 返回值：
#   bool: 数据是否有效
func validate() -> bool:
    if name.is_empty():
        return false
    if build_cost <= 0:
        return false
    if base_damage <= 0:
        return false
    if base_health <= 0:
        return false
    if base_attack_speed <= 0:
        return false
    if base_range <= 0:
        return false
    if max_level < 1:
        return false
    return true
