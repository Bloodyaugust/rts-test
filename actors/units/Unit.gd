extends CharacterBody2D

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

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "unit_selection":
      _draw_selection = self in substate

func _process(delta):
  if _health <= 0:
    queue_free()
    return

  if _move_target:
    global_translate((_move_target - global_position).normalized() * Data.move_speed * delta)

    if global_position.distance_to(_move_target) <= 5.0:
      _move_target = null

  queue_redraw()

func _ready():
  Store.state_changed.connect(_on_store_state_changed)
  _health = Data.health
