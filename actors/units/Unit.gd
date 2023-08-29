extends CharacterBody2D

@export var Data: UnitData
@export var Team: int

@onready var _nav_agent: NavigationAgent2D = %NavigationAgent2D

var _draw_selection: bool
var _health: float
var _move_target
var _safe_velocity

func damage(amount: float) -> void:
  _health -= amount

func move(pos: Vector2) -> void:
  _nav_agent.target_position = pos
  _move_target = _nav_agent.get_next_path_position()

func _draw():
  if _draw_selection:
    draw_arc(Vector2.ZERO, 50.0, 0.0, 2.0 * PI, 32, Color.GREEN, 1.0)
    
    if _move_target:
      var _path_positions: Array = Array(_nav_agent.get_current_navigation_path()).map(func(_position): return (_position - global_position).rotated(-rotation))
      
      draw_polyline(_path_positions, Color.GREEN)

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "unit_selection":
      _draw_selection = self in substate

func _on_safe_velocity_calculated(safe_velocity: Vector2) -> void:
  _safe_velocity = safe_velocity

func _physics_process(delta):
  if _health > 0:
    if _move_target:
      _move_target = _nav_agent.get_next_path_position()
      velocity = (_move_target - global_position).normalized() * Data.move_speed
      _nav_agent.velocity = velocity
      if _safe_velocity:
        velocity = _safe_velocity.normalized() * Data.move_speed
      move_and_slide()
      velocity = (_move_target - global_position).normalized() * Data.move_speed
      
      var _target_rotation = global_position.angle_to_point(_move_target)
      rotation = _target_rotation

      if _nav_agent.is_navigation_finished():
        _move_target = null

func _process(delta):
  if _health <= 0:
    if self in Store.state.unit_selection:
      Store.state.unit_selection.erase(self)
    queue_free()
    return

  queue_redraw()

func _ready():
  Store.state_changed.connect(_on_store_state_changed)
  _nav_agent.velocity_computed.connect(_on_safe_velocity_calculated)
  _health = Data.health
