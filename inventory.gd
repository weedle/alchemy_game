extends Control

class_name Inventory

var items: Array[Sprite2D]

var textures: Dictionary[String, Resource]


func init():
	for child_node in get_children():
		if(child_node.name.begins_with("ItemSlot")):
			items.append(child_node)


	textures["rose"] = load("res://assets/items/item_rose.png")

func add_item(item_type: String):
	# first, check if we already have the item
	for item_slot in items:
		if item_slot.get_meta("ItemType") == item_type:
			# we found it! increase capacity
			item_slot.set_meta("Capacity", str(int(item_slot.get_meta("Capacity")) + 1))
			item_slot.get_child(0).set_text(item_slot.get_meta("Capacity"))
			return

	# ok we don't have it yet, populate the first empty slot we can find
	for item_slot in items:
		if item_slot.get_meta("ItemType") == "":
			item_slot.set_texture(textures[item_type])
			item_slot.set_meta("ItemType", item_type)
			item_slot.set_meta("Capacity", 1)
			item_slot.get_child(0).set_text("1")
			return
