extends CharacterBody2D

@export var Data: UnitData
@export var Team: int

@onready var _nav_agent: NavigationAgent2D = %NavigationAgent2D

var _draw_selection: bool
var _health: float
var _move_target

func damage(amount: float) -> void:
  _health -= amount

func move(pos: Vector2) -> void:
  _nav_agent.target_position = pos
  _move_target = _nav_agent.get_next_path_position()

func _draw():
  if _draw_selection:
    draw_arc(Vector2.ZERO, 50.0, 0.0, 2.0 * PI, 32, Color.GREEN, 1.0)
    
    if _move_target:
      draw_line(Vector2.ZERO, _nav_agent.get_final_position() - global_position, Color.GREEN, 1.0)

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "unit_selection":
      _draw_selection = self in substate

func _physics_process(delta):
  if _health > 0:
    if _move_target:
      _move_target = _nav_agent.get_next_path_position()
      velocity = (_move_target - global_position).normalized() * Data.move_speed
      move_and_slide()

      if _nav_agent.is_navigation_finished():
        _move_target = null

func _process(delta):
  if _health <= 0:
    queue_free()
    return

  queue_redraw()

func _ready():
  Store.state_changed.connect(_on_store_state_changed)
  _health = Data.health
