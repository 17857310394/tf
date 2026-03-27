extends Node3D

# 引入常量库
const Constants = preload("res://scripts/constants.gd")

# 玩家是否在触发区域内
var player_in_area: bool = false

# 建筑预制体
var ground_attack_tower_prefab: PackedScene

# 建造状态
var has_built: bool = false

# 玩家注视状态
var player_looking: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# $Area3D.body_entered.connect(_on_body_entered)
	# $Area3D.body_exited.connect(_on_body_exited)
	
	# 加载建筑预制体
	ground_attack_tower_prefab = preload("res://scenes/towers/GroundAttackTower.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# 处理玩家输入
	if player_looking:
		if Input.is_action_just_pressed("interact"):
			if not has_built:
				build_tower()
			else:
				upgrade_tower()
		if Input.is_action_just_pressed("sold") and has_built:
			sell_tower()
	
	# 检测玩家注视
	_check_player_looking()

# 建造炮塔
func build_tower() -> void:
	# 获取玩家数据
	var player_data = GameManager.instance.get_player_data()
	if not player_data:
		print("Error: PlayerData not found")
		return
	
	# 获取建造成本
	var tower_cost = 100  # 默认建造成本
	
	# 尝试从 prefab 中获取 TowerData
	var prefab_instance = ground_attack_tower_prefab.instantiate()
	var tower_data = prefab_instance.tower_data
	if tower_data.has_method("build_cost"):
		tower_cost = tower_data.build_cost
		print("Got tower cost from TowerData: " + str(tower_cost))
	prefab_instance.queue_free()  # 销毁临时实例
	
	# 检查玩家是否有足够的金币
	if not player_data.remove_gold(tower_cost):
		print("Not enough gold to build tower! Need: " + str(tower_cost))
		return
	
	# 实例化地面攻击炮塔
	var tower_instance = ground_attack_tower_prefab.instantiate()
	
	# 设置炮塔位置与TowerBase一致
	tower_instance.global_position = global_position
	tower_instance.global_rotation = global_rotation
	
	# 将炮塔添加到场景中
	$Tower.add_child(tower_instance)
	
	# 标记为已建造
	has_built = true
	
	refresh_interactive_ui()
	# 隐藏当前的TowerBase
	$MeshInstance3D.hide()
	
	print("炮塔建造完成")

# 升级炮塔
func upgrade_tower() -> void:
	# 获取炮塔实例
	var tower_instance = $Tower.get_child(0)
	if not tower_instance:
		print("Error: Tower instance not found")
		return
	
	# 检查是否可以升级
	if not tower_instance.has_method("upgrade"):
		print("Error: Tower instance has no upgrade method")
		return
	
	# 调用升级方法
	tower_instance.upgrade()
	print("炮塔升级完成")

# 出售炮塔
func sell_tower() -> void:
	# 获取炮塔实例
	var tower_instance = $Tower.get_child(0)
	if not tower_instance:
		print("Error: Tower instance not found")
		return
	
	# 调用出售方法
	tower_instance.sell()
	
	# 标记为未建造
	has_built = false

	refresh_interactive_ui()
	# 显示当前的TowerBase
	$MeshInstance3D.show()

# 检测玩家是否注视该单位
func _check_player_looking() -> void:
	# 查找玩家控制器
	var player_controller = get_tree().root.get_node_or_null("GameScene/PlayerController")
	if not player_controller:
		return
	
	# 检查玩家控制器当前聚焦的物体是否是自己
	var is_looking = player_controller.focused_object == $StaticBody3D
	
	# 如果状态发生变化，更新状态
	if is_looking != player_looking:
		player_looking = is_looking
		refresh_interactive_ui()
		
				
func refresh_interactive_ui() -> void:
	if player_looking:
		print("玩家开始注视该单位")
		# 检查 UIManager 是否存在
		if !has_built:
			UIManager.instance.emit_event(NoteType.player_main_interactive,true, "按“E”建造")
		else:
			UIManager.instance.emit_event(NoteType.player_main_interactive,true, "按“E”升级、按“F“出售")
			
	else:
		print("玩家不再注视该单位")
		# 检查 UIManager 是否存在
		UIManager.instance.emit_event(NoteType.player_main_interactive,false)