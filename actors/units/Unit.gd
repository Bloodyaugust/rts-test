extends Area2D

const MAX_SWARM_SIZE: int = 15
const SWARM_AREA_SIZE: float = 125.0
const SWARM_SEPARATION_AREA_SIZE: float = 80.0

@export var Data: UnitData
@export var Team: int

@onready var _swarm_area: Area2D = %SwarmArea

var _draw_selection: bool
var _health: float
var _move_target
var _idle_target: Vector2 = Vector2.ZERO
var _swarm: Array = []

func damage(amount: float) -> void:
  _health -= amount

func move(pos: Vector2) -> void:
  _move_target = pos
  _idle_target = pos

func _draw():
  if _draw_selection:
    draw_arc(Vector2.ZERO, 50.0, 0.0, 2.0 * PI, 32, Color.GREEN, 1.0)
    
    if _move_target:
      draw_line(Vector2.ZERO, (_move_target - global_position).rotated(-rotation), Color.GREEN)

func _on_store_state_changed(state_key: String, substate) -> void:
  match state_key:
    "unit_selection":
      _draw_selection = self in substate

func _on_swarm_area_entered(area: Area2D) -> void:
  if _swarm.size() < MAX_SWARM_SIZE:
    var _swarm_parent: Node2D = area.get_parent()

    if _swarm_parent.Team == Team:
      _swarm.append(_swarm_parent)
      _swarm_parent.tree_exiting.connect(_on_swarm_area_exited.bind(area))
  
func _on_swarm_area_exited(area: Area2D) -> void:
  var _swarm_parent: Node2D = area.get_parent()
  
  if _swarm_parent.Team == Team && _swarm_parent in _swarm:
    _swarm.erase(_swarm_parent)
    _swarm_parent.tree_exiting.disconnect(_on_swarm_area_exited)

func _physics_process(delta):
  if _health > 0:
    var _swarm_heading: Vector2 = _swarm.reduce(func(a: Vector2, swarm_member: Node2D): return Vector2.from_angle(swarm_member.global_rotation), Vector2.ZERO).normalized()
    var _swarm_separation: Vector2 = _swarm.filter(func(swarm_member: Node2D): return swarm_member.global_position.distance_to(global_position) <= SWARM_SEPARATION_AREA_SIZE).reduce(func(a: Vector2, swarm_member: Node2D): return -(swarm_member.global_position - global_position), Vector2.ZERO).normalized() * 5.0
    var _used_target: Vector2 = _move_target if _move_target else _idle_target
    var _target_direction: Vector2 = (_used_target - global_position).normalized() * clampf(_used_target.distance_to(global_position) / 50.0, 0.5, 2.0)
    
    var _end_rotation_target: float = (_swarm_heading + _swarm_separation + _target_direction).normalized().angle()
    var _rotation_distance: float = wrapf(_end_rotation_target - global_rotation, -PI, PI)
    
    global_rotation += clamp(Data.rotation_speed * delta, 0, abs(_rotation_distance)) * sign(_rotation_distance)
    
    translate(Vector2.from_angle(global_rotation).normalized() * Data.move_speed * delta)

func _process(delta):
  if _health <= 0:
    if self in Store.state.unit_selection:
      Store.state.unit_selection.erase(self)
    queue_free()
    return

  queue_redraw()

func _ready():
  Store.state_changed.connect(_on_store_state_changed)
  _swarm_area.area_entered.connect(_on_swarm_area_entered)
  _swarm_area.area_exited.connect(_on_swarm_area_exited)
  _health = Data.health
  _idle_target = global_position
