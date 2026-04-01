extends "./State.gd"

# 追击状态

var ai = null

func _init():
	state_name = "ChaseState"

func set_ai(ai_instance):
	ai = ai_instance

func _ready():
	# 状态就绪
	print("ChaseState ready")

func enter_state():
	# 进入状态
	print("Starting chase")

func exit_state():
	# 退出状态
	print("Stopping chase")

func process(delta):
	# 处理追击逻辑
	if not ai or not ai.get_ai_character() or not ai.get_target() or not is_instance_valid(ai.get_target()):
		return
	
	var character = ai.get_ai_character()
	var target = ai.get_target()
	var navigation_agent = character.get_node_or_null("NavigationAgent3D")
	
	# 更新导航代理的目标位置
	if navigation_agent:
		navigation_agent.target_position = target.global_position
		
		# 检查是否到达目标
		if not navigation_agent.is_navigation_finished():
			# 获取下一个路径点
			var next_path_position = navigation_agent.get_next_path_position()
			# 向路径点移动
			var direction = character.global_position.direction_to(next_path_position)
			character.velocity = direction * ai.get_movement_speed() * 1.5  # 追击时速度稍快
			character.move_and_slide()
	else:
		# 如果没有导航代理，使用直接移动
		# 计算到目标的方向
		var direction = character.global_position.direction_to(target.global_position)
		
		# 向目标移动
		character.velocity = direction * ai.get_movement_speed() * 1.5  # 追击时速度稍快
		character.move_and_slide()
	
	# 打印追击信息
	var distance = character.global_position.distance_to(target.global_position)
	print("Chasing target, distance: ", distance)
