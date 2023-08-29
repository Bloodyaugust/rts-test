extends Node2D

@export var MoveTarget: Node2D
@export var Team: int
@export var UnitScene: PackedScene
@export var SpawnInterval: float

@onready var _map: Node2D = get_tree().get_first_node_in_group("map")

var _time_to_spawn: float

func _ready():
  _time_to_spawn = SpawnInterval

func _process(delta):
  _time_to_spawn -= delta

  if _time_to_spawn <= 0.0:
    var _new_unit: Node2D = UnitScene.instantiate()

    _new_unit.global_position = global_position + Vector2(randf_range(-5.0, 5.0), randf_range(-5.0, 5.0))
    _new_unit.Team = Team
    _map.add_child(_new_unit)
    _new_unit.move(MoveTarget.global_position if MoveTarget else global_position + Vector2(randf_range(-5.0, 5.0), randf_range(-5.0, 5.0)))

    _time_to_spawn = SpawnInterval
