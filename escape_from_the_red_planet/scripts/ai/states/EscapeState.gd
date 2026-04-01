extends "./State.gd"

# 逃跑状态

var ai = null
var escape_direction = Vector3.ZERO
var escape_timer = 0.0
var escape_duration = 5.0

func _init():
	state_name = "EscapeState"

func set_ai(ai_instance):
	ai = ai_instance

func _ready():
	# 状态就绪
	print("EscapeState ready")

func enter_state():
	# 进入状态
	print("Starting escape")
	escape_timer = 0.0
	
	# 计算逃跑方向（远离目标）
	if ai and ai.get_ai_character() and ai.get_target() and is_instance_valid(ai.get_target()):
		var character = ai.get_ai_character()
		var target = ai.get_target()
		escape_direction = character.global_position.direction_to(target.global_position) * -1  # 反方向
		print("Escaping in direction: ", escape_direction)

func exit_state():
	# 退出状态
	print("Stopping escape")

func process(delta):
	# 处理逃跑逻辑
	if not ai or not ai.get_ai_character():
		return
	
	var character = ai.get_ai_character()
	var navigation_agent = character.get_node_or_null("NavigationAgent3D")
	
	# 计算逃跑方向（远离目标）
	if ai.get_target() and is_instance_valid(ai.get_target()):
		var target = ai.get_target()
		escape_direction = character.global_position.direction_to(target.global_position) * -1  # 反方向
		
		# 使用导航代理逃跑
		if navigation_agent:
			# 计算逃跑目标点
			var escape_target = character.global_position + escape_direction * 20.0  # 向反方向移动20个单位
			navigation_agent.target_position = escape_target
			
			# 检查是否到达逃跑目标
			if not navigation_agent.is_navigation_finished():
				# 获取下一个路径点
				var next_path_position = navigation_agent.get_next_path_position()
				# 向路径点移动
				var direction = character.global_position.direction_to(next_path_position)
				character.velocity = direction * ai.get_movement_speed() * 2.0  # 逃跑时速度更快
				character.move_and_slide()
		else:
			# 如果没有导航代理，使用直接移动
			character.velocity = escape_direction * ai.get_movement_speed() * 2.0  # 逃跑时速度更快
			character.move_and_slide()
	else:
		# 如果没有目标，随机移动
		character.velocity = escape_direction * ai.get_movement_speed() * 2.0  # 逃跑时速度更快
		character.move_and_slide()
	
	# 逃跑计时
	escape_timer += delta
	if escape_timer >= escape_duration:
		# 逃跑时间结束，随机改变方向
		escape_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized()
		escape_timer = 0.0
		print("Changing escape direction: ", escape_direction)
	
	# 打印逃跑信息
	if ai.get_target() and is_instance_valid(ai.get_target()):
		var distance = character.global_position.distance_to(ai.get_target().global_position)
		print("Escaping from target, distance: ", distance)
