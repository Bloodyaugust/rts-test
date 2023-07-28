extends Area2D

@export var Data: ProjectileData

var target: Dictionary
var team: int

var _range_traveled: float

func _process(delta):
  if !target || !target.get("global_position"):
    queue_free()
    return

  _range_traveled += Data.move_speed * delta
  translate(transform.x.normalized() * delta * Data.move_speed)

  if _range_traveled >= Data.move_range:
    queue_free()

func _on_hit_box_body_entered(body: Node2D):
  if body && GDUtil.reference_safe(body) && body.Team != team:
    body.damage(Data.damage)
    queue_free()

func _ready():
  body_entered.connect(_on_hit_box_body_entered)
  look_at(target.global_position)
