extends Area2D

@export var Data: UnitData
@export var Team: int

var _draw_selection: bool
var _health: float
var _move_target

func damage(amount: float) -> void:
  _health -= amount

func move(pos: Vector2) -> void:
  _move_target = pos

func _draw():
  if _draw_selection:
    draw_arc(Vector2.ZERO, 50.0, 0.0, 2.0 * PI, 32, Color.GREEN, 1.0)
    
    if _move_target:
      draw_line(Vector2.ZERO, (_move_target - global_position).rotated(-rotation), Color.GREEN)

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "unit_selection":
      _draw_selection = self in substate

func _physics_process(delta):
  if _health > 0:
    if _move_target != null:
      translate((_move_target - global_position).normalized() * (Data.move_speed) * delta)
      
      var _target_rotation = global_position.angle_to_point(_move_target)
      rotation = _target_rotation

      if global_position.distance_squared_to(_move_target) <= (Data.move_speed * 2) * delta:
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
  _health = Data.health
