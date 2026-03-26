# EventSystem 使用文档

## 系统概述

EventSystem是一个独立的事件系统，用于在Godot项目中实现模块间的通信。它不依赖于任何UI框架，可以在服务端、工具类、数据处理模块等非UI环境中正常运行。

## 核心功能

- **事件注册**：注册事件监听器，支持优先级
- **事件触发**：触发事件并传递参数
- **事件注销**：注销事件监听器
- **一次性事件**：注册只触发一次的事件监听器
- **事件优先级**：设置事件监听器的优先级，控制执行顺序
- **事件节流**：限制事件触发频率
- **事件防抖**：延迟执行事件，避免频繁触发

## 快速开始

### 1. 添加EventSystem到自动加载

- 打开Godot编辑器
- 进入项目设置 → 自动加载
- 添加 `res://scripts/core/EventSystem.gd` 并设置名称为 `EventSystem`

### 2. 基本使用

#### 注册事件监听器

```gdscript
# 注册事件监听器
EventSystem.instance.on("player_jump", _on_player_jump)

# 注册带优先级的事件监听器
EventSystem.instance.on("enemy_spawn", _on_enemy_spawn, 10)  # 优先级10

# 注册一次性事件监听器
EventSystem.instance.once("game_start", _on_game_start)
```

#### 触发事件

```gdscript
# 触发事件
EventSystem.instance.emit("player_jump", "Player1", 10.5)

# 触发带多个参数的事件
EventSystem.instance.emit("enemy_spawn", "Goblin", 5, Vector3(0, 0, 0))
```

#### 注销事件监听器

```gdscript
# 注销特定事件监听器
EventSystem.instance.off("player_jump", _on_player_jump)
```

#### 节流和防抖

```gdscript
# 节流事件（1秒内最多触发一次）
EventSystem.instance.throttle("button_click", func():
    print("Button clicked")
, 1.0)

# 防抖事件（500毫秒内多次触发只执行最后一次）
EventSystem.instance.debounce("input_change", func():
    print("Input changed")
, 0.5)
```

## API文档

### 核心方法

#### `on(event_name: String, callback: Callable, priority: int = 0, once: bool = false) -> void`
- **功能**：注册事件监听器
- **参数**：
  - `event_name`：事件名称
  - `callback`：回调函数
  - `priority`：优先级，值越大优先级越高
  - `once`：是否为一次性事件

#### `once(event_name: String, callback: Callable, priority: int = 0) -> void`
- **功能**：注册一次性事件监听器
- **参数**：
  - `event_name`：事件名称
  - `callback`：回调函数
  - `priority`：优先级

#### `off(event_name: String, callback: Callable) -> void`
- **功能**：注销事件监听器
- **参数**：
  - `event_name`：事件名称
  - `callback`：回调函数

#### `emit(event_name: String, ...) -> void`
- **功能**：触发事件
- **参数**：
  - `event_name`：事件名称
  - `...`：可变参数，传递给回调函数

#### `throttle(event_name: String, callback: Callable, delay: float) -> void`
- **功能**：节流事件
- **参数**：
  - `event_name`：事件名称
  - `callback`：回调函数
  - `delay`：延迟时间（秒）

#### `debounce(event_name: String, callback: Callable, delay: float) -> void`
- **功能**：防抖事件
- **参数**：
  - `event_name`：事件名称
  - `callback`：回调函数
  - `delay`：延迟时间（秒）

#### `has_listeners(event_name: String) -> bool`
- **功能**：检查事件是否有监听器
- **参数**：
  - `event_name`：事件名称
- **返回**：是否有监听器

#### `get_listener_count(event_name: String) -> int`
- **功能**：获取事件监听器数量
- **参数**：
  - `event_name`：事件名称
- **返回**：监听器数量

#### `clear_all() -> void`
- **功能**：清空所有事件

## 使用场景

### 1. 游戏核心逻辑

```gdscript
# 游戏管理器
func _ready() -> void:
    # 注册游戏事件
    EventSystem.instance.on("player_death", _on_player_death)
    EventSystem.instance.on("level_complete", _on_level_complete)

func _on_player_death(player: Node) -> void:
    print("Player died: " + player.name)
    # 处理玩家死亡逻辑

func _on_level_complete(level: int) -> void:
    print("Level " + str(level) + " completed")
    # 处理关卡完成逻辑
```

### 2. UI系统

```gdscript
# UI管理器
func _ready() -> void:
    # 注册UI事件
    EventSystem.instance.on("score_update", _on_score_update)
    EventSystem.instance.on("health_change", _on_health_change)

func _on_score_update(score: int) -> void:
    $ScoreLabel.text = "Score: " + str(score)

func _on_health_change(health: int, max_health: int) -> void:
    $HealthBar.value = float(health) / max_health
```

### 3. 网络模块

```gdscript
# 网络管理器
func _ready() -> void:
    # 注册网络事件
    EventSystem.instance.on("network_connected", _on_network_connected)
    EventSystem.instance.on("network_disconnected", _on_network_disconnected)

func _on_network_connected() -> void:
    print("Network connected")
    # 处理网络连接逻辑

func _on_network_disconnected() -> void:
    print("Network disconnected")
    # 处理网络断开逻辑
```

## 性能优化策略

1. **事件命名规范**：使用清晰、描述性的事件名称，避免使用过于通用的名称
2. **及时注销事件**：在不需要时及时注销事件监听器，避免内存泄漏
3. **避免频繁触发**：对于频繁触发的事件，使用节流或防抖
4. **合理设置优先级**：根据需要设置事件监听器的优先级，确保关键逻辑优先执行
5. **错误处理**：在事件回调中添加错误处理，避免单个回调错误影响其他回调

## 示例代码

### 完整示例

```gdscript
# EventSystemExample.gd
extends Node

func _ready() -> void:
    # 注册事件监听器
    EventSystem.instance.on("player_jump", _on_player_jump)
    EventSystem.instance.once("game_start", _on_game_start)
    
    # 触发事件
    EventSystem.instance.emit("player_jump", "Player1", 10.5)
    EventSystem.instance.emit("game_start", "Level 1")
    EventSystem.instance.emit("game_start", "Level 2")  # 不会触发

func _on_player_jump(event_name: String, player_name: String, height: float) -> void:
    print("Player " + player_name + " jumped " + str(height) + " units")

func _on_game_start(event_name: String, level: String) -> void:
    print("Game started on " + level)
```

## 总结

EventSystem提供了一个灵活、高效的事件系统，可以在Godot项目的各个模块中使用。它支持多种高级特性，如事件优先级、命名空间、节流和防抖等，可以满足不同场景的需求。通过合理使用EventSystem，可以使代码更加模块化、松耦合，提高代码的可维护性和可扩展性。