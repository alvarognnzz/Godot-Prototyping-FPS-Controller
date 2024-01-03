extends CenterContainer

@export var DOT_RADIUS: float = 2.0
@export var DOT_DEFAULT_COLOR: Color = Color.WHITE
@export var DOT_COLLIDING_COLOR: Color = Color.RED

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var draw_color: Color = DOT_COLLIDING_COLOR if Global.HEAD_RAYCAST_COLLIDING else DOT_DEFAULT_COLOR
	draw_circle(Vector2(0,0), DOT_RADIUS, draw_color)
