# GameManager.gd
# 游戏管理器类，用于管理游戏全局数据

class_name GameManager extends Node

# 单例实例
static var instance: GameManager

# 玩家数据
var player_data: PlayerData

# 初始化
func _ready() -> void:
	instance = self
	
	# 初始化玩家数据
	var PlayerData = preload("res://scripts/player/PlayerData.gd")
	player_data = PlayerData.new()

# 获取单例实例
static func get_instance() -> GameManager:
	if not instance:
		print("Error: GameManager instance not found")
	return instance

# 获取玩家数据
func get_player_data() -> PlayerData:
	return player_data