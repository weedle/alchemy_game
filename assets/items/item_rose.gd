extends Item

class_name ItemRose
static var item_type = "rose"
static var icon_location = "assets/items/item_rose.png"
var num = 3
func _init():
	pass

func pickup():
	num -= 1
	print("An item has been picked! There are " + str(num) + " left")
	if num > 0:
		set_meta("NumLeft", num)
	else:
		queue_free()
