extends Node2D

var _selection_box_start
var _do_selection: bool = false

func _draw():
  if _selection_box_start:
    draw_rect(Rect2(_selection_box_start, get_global_mouse_position() - _selection_box_start).abs(), Color.GREEN, false, 4.0)

func _physics_process(delta):
 if _do_selection:
   var _mouse_position: Vector2 = get_global_mouse_position()
   var _physics: PhysicsDirectSpaceState2D = get_world_2d().get_direct_space_state()
   var _shape_query_params: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()

   var _selection_rect: RectangleShape2D = RectangleShape2D.new()
   var _temp_rect = Rect2(_selection_box_start, get_global_mouse_position() - _selection_box_start).abs()
   _selection_rect.size = _temp_rect.size
   _shape_query_params.shape = _selection_rect
   _shape_query_params.transform = Transform2D(0.0, _temp_rect.get_center())
   _shape_query_params.collide_with_areas = true

   var _query_results = _physics.intersect_shape(_shape_query_params, 4096).map(func(dict): return dict["collider"]).filter(func(collider): return collider.has_method("move"))
   _selection_box_start = null
   _do_selection = false

   Store.set_state("unit_selection", _query_results)

func _process(delta):
  queue_redraw()

func _unhandled_input(event):
  if event is InputEventMouseButton:
    if event.is_action_pressed("select_unit"):
      _selection_box_start = get_global_mouse_position()

    if event.is_action_released("select_unit"):
      _do_selection = true

    if event.is_action_released("unit_order"):
      for _unit in Store.state["unit_selection"]:
        _unit.move(get_global_mouse_position())
