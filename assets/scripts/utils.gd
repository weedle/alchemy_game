extends Node
class_name Utils

static func dist_between_points(p1: Vector2, p2: Vector2) -> float:
	return sqrt((p1.y - p2.y)**2 + (p1.x - p2.x)**2)
