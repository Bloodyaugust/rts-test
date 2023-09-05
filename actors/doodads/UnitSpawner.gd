extends Node2D

const MAX_NUM_UNITS: int = 150

@export var MoveTarget: Node2D
@export var Team: int
@export var UnitScene: PackedScene
@export var SpawnEnabled: bool
@export var SpawnInterval: float

@onready var _map: Node2D = get_tree().get_first_node_in_group("map")

var _time_to_spawn: float

func _ready():
  _time_to_spawn = SpawnInterval

func _process(delta):
  if SpawnEnabled:
    _time_to_spawn -= delta

    if _time_to_spawn <= 0.0 && get_tree().get_nodes_in_group("units").size() < MAX_NUM_UNITS:
      var _new_unit: Node2D = UnitScene.instantiate()

      _new_unit.global_position = global_position
      _new_unit.Team = Team
      _map.add_child(_new_unit)
      
      if MoveTarget:
        _new_unit.move(MoveTarget.global_position)

      _time_to_spawn = SpawnInterval
