extends "./State.gd"

# 空闲状态

var ai = null
var idle_timer = 0.0
var max_idle_time = 3.0

func _init():
	state_name = "IdleState"

func set_ai(ai_instance):
	ai = ai_instance

func _ready():
	# 状态就绪
	print("IdleState ready")

func enter_state():
	# 进入状态
	print("Entering idle state")
	idle_timer = 0.0

func exit_state():
	# 退出状态
	print("Exiting idle state")

func process(delta):
	# 处理空闲逻辑
	if not ai or not ai.get_ai_character():
		return
	
	var character = ai.get_ai_character()
	
	# 停止移动
	character.velocity = Vector3.ZERO
	character.move_and_slide()
	
	# 空闲计时
	idle_timer += delta
	if idle_timer >= max_idle_time:
		# 空闲时间结束，随机决定下一步行动
		if randf() < 0.5:
			# 50% 几率开始巡逻
			if ai:
				ai.transition_to("PatrolState")
		idle_timer = 0.0
	
	# 打印空闲信息
	print("Idling, time: ", idle_timer)
