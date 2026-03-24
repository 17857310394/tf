extends Area3D

# 引入常量库
const Constants = preload("res://scripts/constants.gd")

# 触发盒节点
var trigger_area: Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)

# 当物体进入触发盒时调用
func _on_body_entered(body: Node3D) -> void:
	# 检查进入的物体是否为游戏角色
	if body.name == Constants.PLAYER_NAME:
		# 处理角色进入触发盒的逻辑
		print("游戏角色进入了触发盒区域")
		# 在这里添加你的逻辑处理

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
