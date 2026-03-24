# LaserTower.gd
# 激光塔实现类
# 持续伤害，穿透能力，发射激光，持续照射目标，攻击地面敌人，激光可以穿透多个敌人
# 引用TowerData类


class_name LaserTower extends "res://scripts/BaseTower.gd"

# 激光场景路径
var laser_scene = null #preload("res://scenes/laser.tscn")
# 当前激光实例
var current_laser = null
# 激光持续时间
var laser_duration = 0.5
# 激光伤害间隔
var laser_damage_interval = 0.1
# 激光伤害计时器
var laser_damage_timer = 0

# 攻击方法
# 功能：执行激光塔的攻击逻辑，发射持续激光
func attack():
    if not target:
        return
    
    is_attacking = true
    emit_signal("on_attack_started")
    
    # 创建激光
    if not current_laser:
        current_laser = laser_scene.instantiate()
        current_laser.position = global_position + Vector3(0, 1.2, 0)  # 从塔的顶部发射
        get_tree().get_root().add_child(current_laser)
    
    # 更新激光目标
    current_laser.target = target
    current_laser.set_end_position(target.global_position)
    
    # 设置攻击冷却
    attack_cooldown = get_current_attack_speed()
    
    # 旋转塔朝向目标
    look_at(target.global_position, Vector3.UP)
    
    # 重置激光伤害计时器
    laser_damage_timer = 0
    
    is_attacking = false
    emit_signal("on_attack_completed")

# 更新
# 功能：处理激光的持续伤害和状态
# 参数：
#   delta: 帧间隔时间
func _process(delta):
    # 调用父类的_process方法
    super._process(delta)
    
    # 处理激光
    if current_laser:
        if target:
            # 更新激光目标位置
            current_laser.set_end_position(target.global_position)
            
            # 处理持续伤害
            laser_damage_timer += delta
            if laser_damage_timer >= laser_damage_interval:
                # 对目标造成伤害
                target.take_damage(get_current_damage() * laser_damage_interval)
                laser_damage_timer = 0
        else:
            # 目标丢失，销毁激光
            current_laser.queue_free()
            current_laser = null
