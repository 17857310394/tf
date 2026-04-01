extends Node3D

# 主城脚本

@export var tower_data: TowerMainData
# 当前血量
var health = 100

# 最大血量
var max_health = 100

func _ready():
	# 加载配置文件
	max_health = tower_data.max_health
	health = max_health
	print("Main tower health set to: ", health)

# 处理伤害
func take_damage(amount):
	# 更新健康值
	health = max(0, health - amount)
	print("Main tower took ", amount, " damage. Health: ", health)
	
	# 检查是否被摧毁
	if health <= 0:
		_on_main_tower_destroyed()

# 主城被摧毁时的处理
func _on_main_tower_destroyed():
	print("Main tower destroyed!")
	queue_free()
	# 这里可以添加游戏结束逻辑
