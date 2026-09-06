extends Item

class_name ItemSunflower
static var item_type = "sunflower"
static var icon_location = "assets/items/item_sunflower.png"
var num = 4
func _init():
	pass

func pickup():
	num -= 1
	print("An item has been picked! There are " + str(num) + " left")
	if num > 0:
		set_meta("NumLeft", num)
	else:
		queue_free()
