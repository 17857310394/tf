# GroundAttackTower.gd
# 普通塔实现类
# 基础物理攻击，单体伤害，发射子弹，直线飞行，攻击地面敌人

class_name GroundAttackTower extends BaseTower

# 子弹场景路径
var bullet_scene = preload("res://scenes/bullet.tscn")
    
# 攻击方法
# 功能：执行普通塔的攻击逻辑，发射子弹
func attack():
    if not target:
        return
    
    is_attacking = true
    attack_started.emit()
    
    # 发射子弹
    var bullet = bullet_scene.instantiate()
    bullet.position = global_position + Vector3(0, 1, 0)  # 从塔的顶部发射
    bullet.target = target
    bullet.damage = get_current_damage()
    get_tree().get_root().add_child(bullet)
    
    # 设置攻击冷却
    attack_cooldown = get_current_attack_speed()

    # 旋转塔朝向目标（只旋转y轴）
    var direction = (target.global_position - global_position).normalized()
    direction.y = 0  # 忽略y轴分量
    if direction.length() > 0:
        var target_rotation = direction.angle_to(Vector3.FORWARD)
        rotation.y = target_rotation
    
    is_attacking = false
    attack_completed.emit()
