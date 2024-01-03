extends RayCast3D

func _process(delta: float) -> void:
	Global.HEAD_RAYCAST_COLLIDING = is_colliding()
