class_name PlayerController
extends CharacterBody3D

# 移动参数
@export var move_speed: float = 6.0
@export var jump_height: float = 2.0
@export var mouse_sensitivity: float = 0.002
@export var max_pitch: float = PI / 2  # 最大俯仰角度（90度）

# 内部变量
var camera_rotation: Vector3 = Vector3.ZERO

# 节点引用
@onready var camera: Camera3D = $Camera3D

func _ready() -> void:
	# 锁定鼠标到窗口中心
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	# 处理移动输入
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# 处理重力
	velocity.y -= 9.8 * delta
	
	# 处理移动
	if direction.length() > 0:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.1)
		velocity.z = lerp(velocity.z, 0.0, 0.1)
	
	# 处理跳跃
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = sqrt(2 * jump_height * 9.8)
	
	# 应用移动
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# 处理鼠标移动
		_handle_mouse_motion(event)
	
	# 按 ESC 键释放鼠标
	if Input.is_action_just_pressed("pause"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	# 垂直旋转（俯仰）
	camera_rotation.x -= event.relative.y * mouse_sensitivity
	# 限制垂直旋转范围
	camera_rotation.x = clamp(camera_rotation.x, -max_pitch, max_pitch)
	
	# 水平旋转（偏航）
	camera_rotation.y -= event.relative.x * mouse_sensitivity
	
	# 应用旋转到摄像机
	camera.rotation = Vector3(camera_rotation.x, camera_rotation.y, camera_rotation.z)
	# 应用水平旋转到玩家（保持玩家朝向与视角一致）
	rotation.y = camera_rotation.y
