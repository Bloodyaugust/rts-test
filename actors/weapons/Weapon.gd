extends Node2D

@export var Data: WeaponData
@export var ProjectileScene: PackedScene

@onready var _range_box: Area2D = %RangeBox

var _potential_targets: Array[Node2D]
var _target: Node2D
var _time_to_fire: float

func _get_target() -> Node2D:
  for _potential_target in _potential_targets:
    if GDUtil.reference_safe(_potential_target):
      return _potential_target

  return null

func _on_range_box_body_entered(body: Node2D):
  if body.Team != owner.Team && GDUtil.reference_safe(body):
    _potential_targets.append(body)

func _on_range_box_body_exited(body: Node2D):
  if body.Team != owner.Team && GDUtil.reference_safe(body):
    _potential_targets.erase(body)

func _process(delta):
  if !_target || !GDUtil.reference_safe(_target):
    _target = _get_target()

  _time_to_fire -= delta

  if _target && GDUtil.reference_safe(_target):
    look_at(_target.global_position)

    if _time_to_fire <= 0:
      var _new_projectile: Node2D = ProjectileScene.instantiate()

      _new_projectile.global_position = global_position
      _new_projectile.target = {"global_position": _target.global_position}
      _new_projectile.team = owner.Team

      $"/root".add_child(_new_projectile)
      _time_to_fire = Data.fire_interval

func _ready():
  _range_box.body_entered.connect(_on_range_box_body_entered)

  _time_to_fire = Data.fire_interval
