extends Control

class_name Inventory

var items: Array[Sprite2D]

func init():
	for child_node in get_children():
		if(child_node.name.begins_with("ItemSlot")):
			items.append(child_node)
	print(items)

func add_item(item_type: String):
	print("adding item ", item_type)
	if item_type == "rose":
		var rose_texture = load("res://assets/items/item_rose.png")
		items[0].set_texture(rose_texture)
