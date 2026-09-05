class_name Item

var icon_location = "assets/icon_basic.png"
var num = 1

func execute():
	if num > 1:
		print("Using item")
		num -= 1 
		
func _init():
	print("New Item!")
