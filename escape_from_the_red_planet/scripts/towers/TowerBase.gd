extends Area3D

# 引入常量库
const Constants = preload("res://scripts/constants.gd")

# 触发盒节点
var trigger_area: Area3D

# 玩家是否在触发区域内
var player_in_area: bool = false

# UI提示元素
var build_ui: Label3D

# 建筑预制体
var ground_attack_tower_prefab: PackedScene

# 建造状态
var has_built: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# 加载建筑预制体
	ground_attack_tower_prefab = preload("res://scenes/towers/GroundAttackTower.tscn")
	
	# 创建UI提示元素
	build_ui = Label3D.new()
	build_ui.text = "按E进行建造"
	build_ui.font_size = 24
	build_ui.modulate = Color(1, 1, 1, 1)
	build_ui.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	# 设置UI位置在TowerBase上方
	build_ui.position = Vector3(0, 2, 0)
	add_child(build_ui)
	build_ui.hide()

# 当物体进入触发盒时调用
func _on_body_entered(body: Node3D) -> void:
	# 检查进入的物体是否为游戏角色
	if body.name == Constants.PLAYER_NAME:
		# 处理角色进入触发盒的逻辑
		print("游戏角色进入了触发盒区域")
		player_in_area = true
		build_ui.show()

# 当物体离开触发盒时调用
func _on_body_exited(body: Node3D) -> void:
	# 检查离开的物体是否为游戏角色
	if body.name == Constants.PLAYER_NAME:
		# 处理角色离开触发盒的逻辑
		print("游戏角色离开了触发盒区域")
		player_in_area = false
		build_ui.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# 处理玩家输入
	if player_in_area and Input.is_action_just_pressed("ui_interact") and not has_built:
		build_tower()

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
