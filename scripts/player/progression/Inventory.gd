# Inventory.gd
# Manages character inventory with 20 fixed slots

class_name Inventory
extends Node

# Inventory settings
@export var max_slots: int = 20
var items: Array[BaseItem] = []

# Signals for UI updates
signal inventory_changed()
signal item_added(item: BaseItem, slot_index: int)
signal item_removed(item: BaseItem, slot_index: int)
signal inventory_full()

func _ready():
	# Initialize inventory with empty slots
	items.resize(max_slots)
	for i in range(max_slots):
		items[i] = null

func add_item(item: BaseItem) -> bool:
	"""Add item to first available slot"""
	if not item:
		return false
	
	var empty_slot = find_empty_slot()
	if empty_slot == -1:
		emit_signal("inventory_full")
		return false
	
	items[empty_slot] = item
	emit_signal("item_added", item, empty_slot)
	emit_signal("inventory_changed")
	return true

func add_item_to_slot(item: BaseItem, slot_index: int) -> bool:
	"""Add item to specific slot"""
	if not item or slot_index < 0 or slot_index >= max_slots:
		return false
	
	if items[slot_index] != null:
		return false  # Slot occupied
	
	items[slot_index] = item
	emit_signal("item_added", item, slot_index)
	emit_signal("inventory_changed")
	return true

func remove_item(item: BaseItem) -> bool:
	"""Remove specific item from inventory"""
	if not item:
		return false
	
	var slot_index = items.find(item)
	if slot_index == -1:
		return false
	
	return remove_item_from_slot(slot_index)

func remove_item_from_slot(slot_index: int) -> bool:
	"""Remove item from specific slot"""
	if slot_index < 0 or slot_index >= max_slots:
		return false
	
	var item = items[slot_index]
	if not item:
		return false
	
	items[slot_index] = null
	emit_signal("item_removed", item, slot_index)
	emit_signal("inventory_changed")
	return true

func get_item_at_slot(slot_index: int) -> BaseItem:
	"""Get item at specific slot"""
	if slot_index < 0 or slot_index >= max_slots:
		return null
	return items[slot_index]

func move_item(from_slot: int, to_slot: int) -> bool:
	"""Move item from one slot to another"""
	if from_slot < 0 or from_slot >= max_slots or to_slot < 0 or to_slot >= max_slots:
		return false
	
	if from_slot == to_slot:
		return true  # No movement needed
	
	var from_item = items[from_slot]
	var to_item = items[to_slot]
	
	# Swap items
	items[from_slot] = to_item
	items[to_slot] = from_item
	
	emit_signal("inventory_changed")
	return true

func find_empty_slot() -> int:
	"""Find first empty slot, returns -1 if none available"""
	for i in range(max_slots):
		if items[i] == null:
			return i
	return -1

func get_empty_slot_count() -> int:
	"""Count number of empty slots"""
	var count = 0
	for i in range(max_slots):
		if items[i] == null:
			count += 1
	return count

func get_item_count() -> int:
	"""Count number of items in inventory"""
	return max_slots - get_empty_slot_count()

func is_full() -> bool:
	"""Check if inventory is full"""
	return find_empty_slot() == -1

func is_empty() -> bool:
	"""Check if inventory is empty"""
	return get_item_count() == 0

func has_item(item: BaseItem) -> bool:
	"""Check if inventory contains specific item"""
	return items.has(item)

func has_item_type(item_type: String) -> bool:
	"""Check if inventory contains any item of specified type"""
	for item in items:
		if item and item.get_class() == item_type:
			return true
	return false

func get_items_of_type(item_type: String) -> Array[BaseItem]:
	"""Get all items of specified type"""
	var result: Array[BaseItem] = []
	for item in items:
		if item and item.get_class() == item_type:
			result.append(item)
	return result

func get_all_items() -> Array[BaseItem]:
	"""Get all non-null items in inventory"""
	var result: Array[BaseItem] = []
	for item in items:
		if item:
			result.append(item)
	return result

func clear_inventory():
	"""Remove all items from inventory"""
	for i in range(max_slots):
		items[i] = null
	emit_signal("inventory_changed")

func get_inventory_summary() -> Dictionary:
	"""Get inventory summary for display/save purposes"""
	var summary = {
		"max_slots": max_slots,
		"item_count": get_item_count(),
		"empty_slots": get_empty_slot_count(),
		"items": []
	}
	
	for i in range(max_slots):
		var item = items[i]
		if item:
			summary.items.append({
				"slot": i,
				"name": item.item_name if item.has_method("get_name") else "Unknown Item",
				"type": item.get_class()
			})
	
	return summary

func load_inventory_from_dict(data: Dictionary):
	"""Load inventory state from dictionary (for save/load)"""
	# Clear current inventory
	clear_inventory()
	
	# This will need proper item instantiation when we have item data
	# For now, placeholder
	max_slots = data.get("max_slots", 20)
	items.resize(max_slots)

func save_inventory_to_dict() -> Dictionary:
	"""Save inventory state to dictionary (for save/load)"""
	# This will need proper item serialization when we have item data
	# For now, return basic structure
	return get_inventory_summary()
