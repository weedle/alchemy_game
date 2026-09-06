extends Control

class_name Inventory

var items: Array[Sprite2D]

var textures: Dictionary[String, Resource]


func init():
	for child_node in get_children():
		if(child_node.name.begins_with("ItemSlot")):
			items.append(child_node)

	for item in [ItemRose, ItemSunflower]:
		textures[item.item_type] = load(item.icon_location)

func add_item(item_type: String):
	# first, check if we already have the item
	for item_slot in items:
		if item_slot.get_meta("ItemType") == item_type:
			# we found it! increase capacity
			item_slot.set_meta("NumHeld", str(int(item_slot.get_meta("NumHeld")) + 1))
			item_slot.get_child(0).set_text(item_slot.get_meta("NumHeld"))
			return

	# ok we don't have it yet, populate the first empty slot we can find
	for item_slot in items:
		if item_slot.get_meta("ItemType") == "":
			item_slot.set_texture(textures[item_type])
			item_slot.set_meta("ItemType", item_type)
			item_slot.set_meta("NumHeld", 1)
			item_slot.get_child(0).set_text("1")
			return
