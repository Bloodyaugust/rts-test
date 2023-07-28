extends Node2D

func _unhandled_input(event):
  if event is InputEventMouseButton:
    if event.is_action_released("select_unit"):
      var _units: Array[Node] = get_tree().get_nodes_in_group("units")
      var _mouse_position: Vector2 = get_global_mouse_position()
      var _physics: PhysicsDirectSpaceState2D = get_world_2d().get_direct_space_state()
      var _point_query_params: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
      
      _point_query_params.position = _mouse_position
      
      var _query_results = _physics.intersect_point(_point_query_params).map(func(dict): return dict["collider"])
      
      Store.set_state("unit_selection", _query_results)

    if event.is_action_released("unit_order"):
      for _unit in Store.state["unit_selection"]:
        _unit.move(get_global_mouse_position())
