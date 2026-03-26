extends Area3D

# 引入常量库
const Constants = preload("res://scripts/constants.gd")

# 触发盒节点
var trigger_area: Area3D

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
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# 加载建筑预制体
	ground_attack_tower_prefab = preload("res://scenes/towers/GroundAttackTower.tscn")

# 当物体进入触发盒时调用
func _on_body_entered(body: Node3D) -> void:
	# 检查进入的物体是否为游戏角色
	if body.name == Constants.PLAYER_NAME:
		# 处理角色进入触发盒的逻辑
		player_in_area = true
		UIManager.instance.emit_event(NoteType.player_main_interactive,true)

# 当物体离开触发盒时调用
func _on_body_exited(body: Node3D) -> void:
	# 检查离开的物体是否为游戏角色
	if body.name == Constants.PLAYER_NAME:
		# 处理角色离开触发盒的逻辑
		player_in_area = false
		UIManager.instance.emit_event(NoteType.player_main_interactive,false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# 处理玩家输入
	if player_in_area and Input.is_action_just_pressed("interact") and not has_built:
		build_tower()
	
	# 检测玩家注视
	_check_player_looking()

# 建造炮塔
func build_tower() -> void:
	# 实例化地面攻击炮塔
	var tower_instance = ground_attack_tower_prefab.instantiate()
	
	# 设置炮塔位置与TowerBase一致
	tower_instance.global_position = global_position
	tower_instance.global_rotation = global_rotation
	
	# 将炮塔添加到场景中
	get_parent().add_child(tower_instance)
	
	# 标记为已建造
	has_built = true
	
	# 隐藏当前的TowerBase
	hide()
	
	print("炮塔建造完成")

# 检测玩家是否注视该单位
func _check_player_looking() -> void:
	# 查找玩家控制器
	var player_controller = get_tree().root.get_node_or_null("GameScene/PlayerController")
	if not player_controller:
		return
	
	# 检查玩家控制器当前聚焦的物体是否是自己
	var is_looking = player_controller.focused_object == self
	
	# 如果状态发生变化，更新状态
	if is_looking != player_looking:
		player_looking = is_looking
		if player_looking:
			print("玩家开始注视该单位")
		else:
			print("玩家不再注视该单位")
