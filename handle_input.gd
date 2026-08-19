extends TextEdit

const CLICK_TIME:  int   = 250 # 1/4 second.
const CLICK_RANGE: float = 5.0 # pixels

var mouse_down_pos: Vector2
var mouse_down_dist: int

var is_pressed: bool = false

var chalk = load("res://chalk_node.tscn")

var chalk_nodes = []

func _input(e: InputEvent):
	var pos = get_global_mouse_position()
	if e is InputEventMouseButton:
		if is_pressed != e.pressed:
			var prefix = "released button at " if is_pressed else "clicked button at "
			if is_pressed:
				mouse_down_dist = 0
				mouse_down_pos = pos
			else:
				for chalk_node in chalk_nodes:
					chalk_node.queue_free()
				chalk_nodes = []
					
			self.text = prefix + str(pos)
			is_pressed = e.pressed
	elif e is InputEventMouseMotion:
		if is_pressed:
			mouse_down_dist += mouse_down_pos.distance_to(pos)
			self.text = "mouse is moving " + str(pos) + "\n"
			self.text += "has moved " + str(mouse_down_dist)
			mouse_down_pos = pos
			
			if mouse_down_dist % 10 == 0:
				var new_chalk = chalk.instantiate()
				chalk_nodes.append(new_chalk)
				get_parent().add_child(new_chalk)
				new_chalk.position = pos
				
				
			

func _handle_mouse_click(pos: Vector2) -> void:
	print("Got a click at " + str(pos))

func _handle_mouse_long_click(pos: Vector2, msec: int) -> void:
	print("Got a long (" + str(msec) + "ms) click at " + str(pos))
	
func handle_mouse_drag():
	print();
