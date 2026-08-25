extends TextEdit

const CLICK_TIME:  int   = 250 # 1/4 second.
const CLICK_RANGE: float = 5.0 # pixels

var mouse_down_pos: Vector2
var mouse_down_dist: int

var is_pressed: bool = false

var chalk = load("res://chalk_node.tscn")

var chalk_nodes = []

var line1: Line2D = null
var line2: Line2D = null
var line3: Line2D = null
var line4: Line2D = null
var line5: Line2D = null

var first_line_of_circle_grade: bool = true

var do_lines: bool = true

func _input(e: InputEvent):
	var pos = get_global_mouse_position()
	if e is InputEventMouseButton:
		if is_pressed != e.pressed:
			var prefix = "released button at " if is_pressed else "clicked button at "
			if !is_pressed:
				mouse_down_dist = 0
				mouse_down_pos = pos
				for chalk_node in chalk_nodes:
					chalk_node.queue_free()
				chalk_nodes = []
				for line in [line1, line2, line3, line4, line5]:
					if line != null:
						line.clear_points()
			else:
				var points: Array[Vector2] = []
				for chalk_node in chalk_nodes:
					points.append(chalk_node.position)
				if len(points) > 3:
					if dist_between_points(points[0], points[len(points) - 1]) < 50:
						grade_circle(points)
					else:
						grade_line(points)
					
			print(prefix + str(pos))
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
	
func dist_between_points(p1: Vector2, p2: Vector2) -> float:
	return sqrt((p1.y - p2.y)**2 + (p1.x - p2.x)**2)
	
# get the slope and intercept of the line connecting two points
# return as a Vector2 like [slope, intercept]
func get_slope_and_intercept(p1: Vector2, p2: Vector2) -> Vector2:
	var slope = (p1.y - p2.y) / (p1.x - p2.x)
	var intercept = (p1.y + p2.y - slope * (p1.x + p2.x)) / 2
	
	print("with points ", p1, " and ", p2, " slope is ", slope, " and intercept is ", intercept)
	
	return Vector2(slope, intercept)
	
# Given two points, find the line that perfectly bisects the line connecting them
# Why do we have this? Because this way, we take three points from a circle,
# find where the bisecting lines intersect, and that's our circle center
# Then we can average out the distances to see how good the rest of the circle points are
# return value is slope as x and intercept as y
func find_bisecting_line(p1: Vector2, p2: Vector2) -> Vector2:
	if do_lines:
		if first_line_of_circle_grade:
			line1 = get_parent().get_child(2)
			line1.clear_points()
			line1.add_point(p1)
			line1.add_point(p2)
		else:
			line2 = get_parent().get_child(3)
			line2.clear_points()
			line2.add_point(p1)
			line2.add_point(p2)
		
	var slope = (p1.x - p2.x) / (p2.y - p1.y)
	var intercept = (p1.y + p2.y) / 2 - (p1.x - p2.x) * ((p1.x + p2.x) / 2) / (p2.y - p1.y)
	
	if do_lines:
		if first_line_of_circle_grade:
			line3 = get_parent().get_child(4)
			line3.clear_points()
			line3.add_point(Vector2(-400, -400 * slope + intercept))
			line3.add_point(Vector2(400, 400 * slope + intercept))
			first_line_of_circle_grade = false
		else:
			line4 = get_parent().get_child(5)
			line4.clear_points()
			line4.add_point(Vector2(-400, -400 * slope + intercept))
			line4.add_point(Vector2(400, 400 * slope + intercept))
			first_line_of_circle_grade = true
		
	
	return Vector2(slope, intercept)
	
func sum(values: Array[float]) -> float:
	var total: float = 0
	for val in values:
		total += val
	print("total is ", " ", total)
	return total

# Given the slopes and intercepts of two bisecting lines, find the intersecting point
func find_intersecting_point(l1: Vector2, l2: Vector2) -> Vector2:
	var x = (l1.y - l2.y) / (l2.x - l1.x)
	var y = l1.x * (l1.y - l2.y) / (l2.x - l1.x) + l1.y
	return Vector2(x, y)
	
func grade_circle(points: Array[Vector2]) -> int:
	if(len(points) < 3):
		return 0
	
	# pick three roughly equally distanced points
	var first_index = len(points) / 4
	var second_index = len(points) / 2
	var third_index = 3 * len(points) / 4
	
	print("Checking points at indices ", first_index, ", ", second_index, ", and ", third_index)
	
	var first_bisecting_line: Vector2 = find_bisecting_line(points[first_index], points[second_index])
	
	print("first line ", first_bisecting_line)
	
	var second_bisecting_line: Vector2 = find_bisecting_line(points[second_index], points[third_index])
	
	print("second ", second_bisecting_line)
	
	var circle_center: Vector2 = find_intersecting_point(first_bisecting_line, second_bisecting_line)
	
	print("Center of circle is at ", circle_center)
	
	var distances: Array[float] = []
	var deviations: Array[float] = []
	for point in points:
		distances.append(dist_between_points(point, circle_center))
	var avg_dist = sum(distances)/len(distances)
	for dist in distances:
		#print("diff in distances ", dist, " - ", avg_dist, " = ", dist - avg_dist)
		deviations.append(abs(dist - avg_dist))
		
	var avg_dev = sum(deviations)/len(deviations)
	
	print("avg deviation is ", avg_dev)
	var deviation_points = 0
	if avg_dev < 10:
		deviation_points = 20
	elif avg_dev < 15:
		deviation_points = 10
	elif avg_dev < 30:
		deviation_points = 0
	else:
		deviation_points = -10
		
	var final_dist = dist_between_points(points[0], points[len(points) - 1])
	print("distance between first and last point ", final_dist)
	
	var final_dist_points = 0
	if final_dist < 5:
		final_dist_points = 10
	elif final_dist < 10:
		final_dist_points = 5
	elif final_dist < 20:
		final_dist_points = 0
	elif final_dist < 40:
		final_dist_points = -10
	else:
		final_dist_points = -30
		
	print("average distance from center is ", avg_dist)
	
	var avg_dist_points = 0
	if avg_dist > 80:
		avg_dist_points = 20
	elif avg_dist > 40:
		avg_dist_points = 10
	elif avg_dist > 10:
		avg_dist_points = 0
	else:
		avg_dist_points = -10
		
	var final_score = deviation_points + final_dist_points + avg_dist_points
	print("final score is ", final_score)
	
	
	if final_score > 40:
		self.text = "GRADE S CIRCLE"
	elif final_score > 30:
		self.text = "GRADE A CIRCLE"
	elif final_score > 20:
		self.text = "GRADE B CIRCLE"
	elif final_score > 15:
		self.text = "GRADE C CIRCLE"
	else:
		self.text = "SHIT CIRCLE"
	
	return 0


func grade_line(points: Array[Vector2]) -> int:
	if(len(points) < 5):
		return 0
		
	# Find the rough slope and intercept of the line by using a few key points
	# Look I'm not manually writing a least squares linear regression in gdscript ok
	var p1: Vector2 = points[len(points) / 5]
	var p2: Vector2 = points[2 * len(points) / 5]
	var p3: Vector2 = points[3 * len(points) / 5]
	var p4: Vector2 = points[4 * len(points) / 5]
	
	var vals1: Vector2 = get_slope_and_intercept(p1, p2)
	var vals2: Vector2 = get_slope_and_intercept(p2, p3)
	var vals3: Vector2 = get_slope_and_intercept(p3, p4)
	
	var avg_slope: float = (vals1.x + vals2.x + vals3.x) / 3
	var avg_intercept: float = (vals1.y + vals2.y + vals3.y) / 3
	
	var deviations: Array[float] = []
	
	# Now, for each point in the array, figure out how far it is from our expected line
	for point in points:
		deviations.append(abs(avg_slope * point.x + avg_intercept - point.y))
		#print("added deviation ", abs(avg_slope * point.x + avg_intercept - point.y))
	
	var avg_deviation: float = sum(deviations)/len(deviations)
	print("average deviation ", avg_deviation)
	
	if avg_deviation > 40:
		return 0
	
	line5 = get_parent().get_child(6)
	line5.clear_points()
	line5.add_point(Vector2(points[0].x, points[0].x * avg_slope + avg_intercept))
	line5.add_point(Vector2(points[len(points) - 1].x, points[len(points) - 1].x * avg_slope + avg_intercept))
	
	if avg_deviation < 2:
		self.text = "GRADE S LINE"
	elif avg_deviation < 5:
		self.text = "GRADE A LINE"
	elif avg_deviation < 10:
		self.text = "GRADE B LINE"
	elif avg_deviation < 20:
		self.text = "GRADE C LINE"
	else:
		self.text = "SHIT LINE"
		
		
	
	return 0
