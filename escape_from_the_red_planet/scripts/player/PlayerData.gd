# PlayerData.gd
# 玩家数据类，用于记录玩家的金币、生命值和分数

class_name PlayerData extends Resource

var gold: int = 1000  # 初始金币
var health: int = 100  # 初始生命值
var score: int = 0  # 初始分数

# 增加金币
func add_gold(amount: int) -> void:
	gold += amount
	print("Added gold: " + str(amount) + ", current gold: " + str(gold))
	UIManager.instance.emit_event(NoteType.player_main_money_change)

# 减少金币
func remove_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		print("Removed gold: " + str(amount) + ", current gold: " + str(gold))
		UIManager.instance.emit_event(NoteType.player_main_money_change)
		return true
	else:
		print("Not enough gold! Need: " + str(amount) + ", current: " + str(gold))
		return false