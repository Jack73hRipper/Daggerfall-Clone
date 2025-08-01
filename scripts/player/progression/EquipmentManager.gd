# EquipmentManager.gd
# Manages character equipment slots and bonuses

class_name EquipmentManager
extends Node

# Equipment slot enumeration
enum EquipmentSlot {
	MAIN_HAND,
	OFF_HAND,
	HELMET,
	CHEST,
	LEGS,
	FEET,
	NECK,
	RING_1,
	RING_2,
	CLOAK
}

# Dictionary to store equipped items
var equipped_items: Dictionary = {}

# Signals for UI updates
signal equipment_changed(slot: EquipmentSlot, item: BaseItem)
signal item_equipped(slot: EquipmentSlot, item: BaseItem)
signal item_unequipped(slot: EquipmentSlot, item: BaseItem)

func _ready():
	# Initialize all slots as empty
	for slot in EquipmentSlot.values():
		equipped_items[slot] = null

func equip_item(item: BaseItem, slot: EquipmentSlot) -> bool:
	"""Equip an item to a specific slot"""
	if not item:
		return false
	
	# Check if item can be equipped in this slot
	if not can_equip_item(item, slot):
		return false
	
	# Unequip current item if any
	var old_item = equipped_items.get(slot)
	if old_item:
		unequip_item(slot)
	
	# Equip new item
	equipped_items[slot] = item
	
	# Apply item bonuses (placeholder for now)
	apply_item_bonuses(item)
	
	# Emit signals
	emit_signal("item_equipped", slot, item)
	emit_signal("equipment_changed", slot, item)
	
	return true

func unequip_item(slot: EquipmentSlot) -> BaseItem:
	"""Unequip item from slot and return it"""
	var item = equipped_items.get(slot)
	if not item:
		return null
	
	# Remove item bonuses (placeholder for now)
	remove_item_bonuses(item)
	
	# Clear slot
	equipped_items[slot] = null
	
	# Emit signals
	emit_signal("item_unequipped", slot, item)
	emit_signal("equipment_changed", slot, null)
	
	return item

func get_equipped_item(slot: EquipmentSlot) -> BaseItem:
	"""Get the item equipped in a specific slot"""
	return equipped_items.get(slot)

func is_slot_empty(slot: EquipmentSlot) -> bool:
	"""Check if equipment slot is empty"""
	return equipped_items.get(slot) == null

func can_equip_item(item: BaseItem, slot: EquipmentSlot) -> bool:
	"""Check if an item can be equipped in the specified slot"""
	if not item:
		return false
	
	# Check item's valid equipment slots (we'll add this to BaseItem later)
	# For now, return true as a placeholder
	return true

func get_all_equipped_items() -> Dictionary:
	"""Get all equipped items as a dictionary"""
	var result = {}
	for slot in EquipmentSlot.values():
		var item = equipped_items.get(slot)
		if item:
			result[slot] = item
	return result

func get_equipped_weapon() -> BaseItem:
	"""Get the currently equipped main hand weapon"""
	return equipped_items.get(EquipmentSlot.MAIN_HAND)

func get_equipped_armor() -> BaseItem:
	"""Get the currently equipped chest armor"""
	return equipped_items.get(EquipmentSlot.CHEST)

func calculate_total_armor_class() -> int:
	"""Calculate total AC from all equipped items (placeholder)"""
	var base_ac = 10  # Base AC
	
	# Add armor bonuses (will implement when we add armor items)
	var chest_armor = equipped_items.get(EquipmentSlot.CHEST)
	if chest_armor and chest_armor.has_method("get_armor_bonus"):
		base_ac += chest_armor.get_armor_bonus()
	
	# Add shield bonus
	var shield = equipped_items.get(EquipmentSlot.OFF_HAND)
	if shield and shield.has_method("get_armor_bonus"):
		base_ac += shield.get_armor_bonus()
	
	return base_ac

func apply_item_bonuses(item: BaseItem):
	"""Apply stat bonuses from equipped item (placeholder)"""
	# This will be implemented when we add item bonuses
	pass

func remove_item_bonuses(item: BaseItem):
	"""Remove stat bonuses from unequipped item (placeholder)"""
	# This will be implemented when we add item bonuses
	pass

func get_slot_name(slot: EquipmentSlot) -> String:
	"""Get human-readable name for equipment slot"""
	match slot:
		EquipmentSlot.MAIN_HAND:
			return "Main Hand"
		EquipmentSlot.OFF_HAND:
			return "Off Hand"
		EquipmentSlot.HELMET:
			return "Helmet"
		EquipmentSlot.CHEST:
			return "Chest"
		EquipmentSlot.LEGS:
			return "Legs"
		EquipmentSlot.FEET:
			return "Feet"
		EquipmentSlot.NECK:
			return "Neck"
		EquipmentSlot.RING_1:
			return "Ring 1"
		EquipmentSlot.RING_2:
			return "Ring 2"
		EquipmentSlot.CLOAK:
			return "Cloak"
		_:
			return "Unknown"

func get_equipment_summary() -> Dictionary:
	"""Get equipment summary for save/display purposes"""
	var summary = {}
	for slot in EquipmentSlot.values():
		var item = equipped_items.get(slot)
		if item:
			summary[slot] = {
				"name": item.item_name if item.has_method("get_name") else "Unknown Item",
				"type": item.get_class()
			}
	return summary

func load_equipment_from_dict(data: Dictionary):
	"""Load equipment state from dictionary (for save/load)"""
	# This will need to be implemented with proper item instantiation
	# For now, placeholder
	pass

func save_equipment_to_dict() -> Dictionary:
	"""Save equipment state to dictionary (for save/load)"""
	# This will need to be implemented with proper item serialization
	# For now, placeholder
	return {}
