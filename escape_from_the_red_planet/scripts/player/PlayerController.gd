

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

# 视线检测到的物体
var focused_object: Node3D = null

# 控制状态
var is_controllable: bool = true  # 是否可控制

func _ready() -> void:
	# 锁定鼠标到窗口中心
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	if not is_controllable:
		# 如果不可控制，重置速度并返回
		velocity.x = 0
		velocity.z = 0
		return
	
	# 处理移动输入
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	# 确定移动方向
	var direction: Vector3
	var camera_manager = get_parent().get_node_or_null("CameraManager")
	
	if camera_manager:
		# 检查当前相机模式
		var current_mode = camera_manager.current_mode
		if current_mode == camera_manager.CameraMode.BIRDS_EYE:
			# 鸟瞰视角：使用世界坐标系的绝对方向
			# W: 世界坐标系正Z方向，A: 世界坐标系负X方向
			direction = Vector3(-input_dir.x, 0, -input_dir.y).normalized()
		elif current_mode == camera_manager.CameraMode.THIRD_PERSON:
			# 第三人称视角：使用第三人称相机的变换矩阵
			var third_person_camera = camera_manager.third_person_camera
			if third_person_camera:
				var camera_basis = third_person_camera.global_transform.basis
				direction = (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			else:
				direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
		else:
			# 第一人称视角：使用玩家相机的变换矩阵
			var camera_basis = camera.global_transform.basis
			direction = (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	else:
		# 如果没有CameraManager，使用默认的方向
		direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
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

# 处理视线检测
func _process(_delta: float) -> void:
	# 查找相机管理器
	var camera_manager = get_parent().get_node_or_null("CameraManager")
	if not camera_manager:
		return
	
	# 检查是否为第一人称视角
	if camera_manager.current_mode != camera_manager.CameraMode.FIRST_PERSON:
		# 如果不是第一人称视角，清空聚焦物体
		if focused_object:
			focused_object = null
		return
	
	# 执行视线检测
	var new_focused_object = _detect_looked_at_object()
	
	# 如果聚焦物体发生变化，更新状态并发出事件
	if new_focused_object != focused_object:
		# 更新聚焦物体
		focused_object = new_focused_object

# 检测视线方向上的物体
func _detect_looked_at_object() -> Node3D:
	# 获取相机位置和前向向量
	var camera_pos = camera.global_position
	# 在 Godot 中，相机的前向向量通常是 -z 方向
	var camera_forward = -camera.global_transform.basis.z
	
	# 设置射线长度
	var ray_length = 3  # 增加射线长度
	var ray_end = camera_pos + camera_forward * ray_length
	
	# 创建射线查询参数
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = camera_pos
	ray_query.to = ray_end
	ray_query.exclude = [self]  # 排除自身
	ray_query.collision_mask = 0xFFFFFFFF  # 检测所有碰撞层
	
	# 发射射线
	var space_state = get_world_3d().direct_space_state
	var collision = space_state.intersect_ray(ray_query)

	# 如果有碰撞，返回碰撞对象
	if collision:
		return collision.collider
	
	# 否则返回null
	return null

func _input(event: InputEvent) -> void:
	if not is_controllable:
		# 如果不可控制，不处理输入
		return
	
	if event is InputEventMouseMotion:
		# 处理鼠标移动
		_handle_mouse_motion(event)
	
	# # 按 ESC 键释放鼠标
	# if Input.is_action_just_pressed("pause"):
	# 	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
	# 		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# 	else:
	# 		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	# 直接修改camera_rotation分量实现相机旋转
	
	# 垂直旋转（俯仰）：鼠标上下移动控制
	camera_rotation.x -= event.relative.y * mouse_sensitivity
	# 限制垂直旋转范围，防止过度旋转
	camera_rotation.x = clamp(camera_rotation.x, -max_pitch, max_pitch)
	
	# 水平旋转（偏航）：鼠标左右移动控制
	camera_rotation.y -= event.relative.x * mouse_sensitivity
	
	# 应用旋转到摄像机
	camera.rotation = camera_rotation
	# 应用水平旋转到玩家（保持玩家朝向与视角一致）
	rotation.y = camera_rotation.y
