# CharacterMenu.gd
# Tabbed character menu showing Stats, Equipment, and Inventory

class_name CharacterMenu
extends Control

# Tab buttons
@onready var stats_tab_button: Button
@onready var equipment_tab_button: Button
@onready var inventory_tab_button: Button

# Tab content panels
@onready var stats_panel: Control
@onready var equipment_panel: Control
@onready var inventory_panel: Control

# Character data references
var character_stats: Resource  # CharacterStats
var equipment_manager: EquipmentManager
var inventory: Inventory

# References to dynamic labels for real-time updates
var health_value_label: Label
var mana_value_label: Label
var stamina_value_label: Label

# Current active tab
enum Tab { STATS, EQUIPMENT, INVENTORY }
var current_tab: Tab = Tab.STATS

func _ready():
	print("CharacterMenu: Initializing character menu")
	setup_menu_layout()
	
	# Start hidden
	visible = false
	
	# Connect to escape key to close menu
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _input(event: InputEvent):
	if visible and event.is_action_pressed("ui_cancel"):  # ESC key
		hide_menu()

func setup_menu_layout():
	"""Create the tabbed character menu interface"""
	print("CharacterMenu: Setting up menu layout")
	
	# Set to center of screen
	set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	size = Vector2(800, 600)
	position = position - size / 2  # Ensure it's properly centered
	
	# Add semi-transparent background
	var background = Panel.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.add_theme_color_override("bg_color", Color(0.1, 0.1, 0.1, 0.9))
	add_child(background)
	
	# Create main container
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	add_child(vbox)
	
	# Add title
	var title = Label.new()
	title.text = "CHARACTER MENU"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color.WHITE)
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)
	
	# Create tab buttons container
	var tab_container = HBoxContainer.new()
	tab_container.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(tab_container)
	
	# Create tab buttons
	stats_tab_button = create_tab_button("STATS", Tab.STATS)
	equipment_tab_button = create_tab_button("EQUIPMENT", Tab.EQUIPMENT)
	inventory_tab_button = create_tab_button("INVENTORY", Tab.INVENTORY)
	
	tab_container.add_child(stats_tab_button)
	tab_container.add_child(equipment_tab_button)
	tab_container.add_child(inventory_tab_button)
	
	# Create content area
	var content_area = Panel.new()
	content_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_area.add_theme_color_override("bg_color", Color(0.2, 0.2, 0.2, 0.8))
	vbox.add_child(content_area)
	
	# Create tab panels
	create_stats_panel(content_area)
	create_equipment_panel(content_area)
	create_inventory_panel(content_area)
	
	# Show initial tab
	switch_to_tab(Tab.STATS)
	
	print("CharacterMenu: Menu layout complete")

func create_tab_button(text: String, tab_type: Tab) -> Button:
	"""Create a tab button"""
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(120, 40)
	button.add_theme_color_override("font_color", Color.WHITE)
	
	# Connect button press
	button.pressed.connect(_on_tab_button_pressed.bind(tab_type))
	
	return button

func create_stats_panel(parent: Control):
	"""Create the stats tab panel"""
	stats_panel = Control.new()
	stats_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(stats_panel)
	
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(20, 20)
	vbox.size = Vector2(760, 500)
	stats_panel.add_child(vbox)
	
	# Add stats content
	var stats_title = Label.new()
	stats_title.text = "CHARACTER STATISTICS"
	stats_title.add_theme_color_override("font_color", Color.WHITE)
	stats_title.add_theme_font_size_override("font_size", 18)
	vbox.add_child(stats_title)
	
	# Create stats display (will be populated when data is connected)
	create_stats_display(vbox)

func create_equipment_panel(parent: Control):
	"""Create the equipment tab panel"""
	equipment_panel = Control.new()
	equipment_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(equipment_panel)
	
	var label = Label.new()
	label.text = "EQUIPMENT MANAGER\n\n10 Equipment Slots:\n• Main Hand\n• Off Hand\n• Helmet\n• Chest Armor\n• Leg Armor\n• Feet\n• Neck (Amulet)\n• Ring 1\n• Ring 2\n• Cloak\n\n[Equipment visualization coming soon]"
	label.position = Vector2(20, 20)
	label.add_theme_color_override("font_color", Color.WHITE)
	equipment_panel.add_child(label)

func create_inventory_panel(parent: Control):
	"""Create the inventory tab panel"""
	inventory_panel = Control.new()
	inventory_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(inventory_panel)
	
	var label = Label.new()
	label.text = "INVENTORY SYSTEM\n\n20-Slot Inventory:\n• Item storage and management\n• Move and swap functionality\n• Automatic stacking\n• Right-click context menus\n\n[Inventory grid coming soon]"
	label.position = Vector2(20, 20)
	label.add_theme_color_override("font_color", Color.WHITE)
	inventory_panel.add_child(label)

func create_stats_display(parent: VBoxContainer):
	"""Create the stats display section"""
	if not character_stats:
		var placeholder = Label.new()
		placeholder.text = "Character stats not connected yet..."
		placeholder.add_theme_color_override("font_color", Color.GRAY)
		parent.add_child(placeholder)
		return
	
	# Create stats grid
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 10)
	parent.add_child(grid)
	
	# Add attribute stats
	var attributes = ["STR", "DEX", "CON", "INT", "WIS", "CHA"]
	var values = [
		character_stats.strength,
		character_stats.dexterity, 
		character_stats.constitution,
		character_stats.intelligence,
		character_stats.wisdom,
		character_stats.charisma
	]
	
	for i in range(attributes.size()):
		var attr_name = Label.new()
		attr_name.text = attributes[i] + ":"
		attr_name.add_theme_color_override("font_color", Color.WHITE)
		grid.add_child(attr_name)
		
		var attr_value = Label.new()
		var modifier = character_stats.get_modifier(values[i])
		var modifier_text = "+" + str(modifier) if modifier >= 0 else str(modifier)
		attr_value.text = str(values[i]) + " (" + modifier_text + ")"
		attr_value.add_theme_color_override("font_color", Color.CYAN)
		grid.add_child(attr_value)
	
	# Add derived stats
	parent.add_child(VSeparator.new())
	
	var derived_title = Label.new()
	derived_title.text = "DERIVED STATISTICS"
	derived_title.add_theme_color_override("font_color", Color.WHITE)
	derived_title.add_theme_font_size_override("font_size", 16)
	parent.add_child(derived_title)
	
	var derived_grid = GridContainer.new()
	derived_grid.columns = 2
	derived_grid.add_theme_constant_override("h_separation", 20)
	parent.add_child(derived_grid)
	
	# Health
	var health_label = Label.new()
	health_label.text = "Health:"
	health_label.add_theme_color_override("font_color", Color.WHITE)
	derived_grid.add_child(health_label)
	
	health_value_label = Label.new()
	health_value_label.text = str(character_stats.current_hit_points) + "/" + str(character_stats.max_hit_points)
	health_value_label.add_theme_color_override("font_color", Color.RED)
	derived_grid.add_child(health_value_label)
	
	# Mana
	var mana_label = Label.new()
	mana_label.text = "Mana:"
	mana_label.add_theme_color_override("font_color", Color.WHITE)
	derived_grid.add_child(mana_label)
	
	mana_value_label = Label.new()
	mana_value_label.text = str(character_stats.current_mana_points) + "/" + str(character_stats.max_mana_points)
	mana_value_label.add_theme_color_override("font_color", Color.CYAN)
	derived_grid.add_child(mana_value_label)
	
	# Stamina
	var stamina_label = Label.new()
	stamina_label.text = "Stamina:"
	stamina_label.add_theme_color_override("font_color", Color.WHITE)
	derived_grid.add_child(stamina_label)
	
	stamina_value_label = Label.new()
	stamina_value_label.text = str(character_stats.current_stamina_points) + "/" + str(character_stats.max_stamina_points)
	stamina_value_label.add_theme_color_override("font_color", Color.YELLOW)
	derived_grid.add_child(stamina_value_label)

func _on_tab_button_pressed(tab_type: Tab):
	"""Handle tab button press"""
	switch_to_tab(tab_type)

func switch_to_tab(tab_type: Tab):
	"""Switch to the specified tab"""
	current_tab = tab_type
	
	# Hide all panels
	stats_panel.visible = false
	equipment_panel.visible = false
	inventory_panel.visible = false
	
	# Show selected panel and update button states
	match tab_type:
		Tab.STATS:
			stats_panel.visible = true
			update_button_state(stats_tab_button, true)
			update_button_state(equipment_tab_button, false)
			update_button_state(inventory_tab_button, false)
		Tab.EQUIPMENT:
			equipment_panel.visible = true
			update_button_state(stats_tab_button, false)
			update_button_state(equipment_tab_button, true)
			update_button_state(inventory_tab_button, false)
		Tab.INVENTORY:
			inventory_panel.visible = true
			update_button_state(stats_tab_button, false)
			update_button_state(equipment_tab_button, false)
			update_button_state(inventory_tab_button, true)

func update_button_state(button: Button, is_active: bool):
	"""Update button appearance based on active state"""
	if is_active:
		button.add_theme_color_override("bg_color", Color(0.4, 0.4, 0.6, 1.0))
	else:
		button.remove_theme_color_override("bg_color")

func show_menu():
	"""Show the character menu"""
	visible = true
	print("CharacterMenu: Menu opened")

func hide_menu():
	"""Hide the character menu"""
	visible = false
	print("CharacterMenu: Menu closed")

func toggle_menu():
	"""Toggle menu visibility"""
	if visible:
		hide_menu()
	else:
		show_menu()

func connect_character_data(stats: Resource, equipment: EquipmentManager, inv: Inventory):
	"""Connect character data for display with real-time updates"""
	print("CharacterMenu: Connecting to character data with real-time updates")
	
	# Disconnect previous signals if they exist
	if character_stats:
		if character_stats.is_connected("health_changed", _on_character_health_changed):
			character_stats.disconnect("health_changed", _on_character_health_changed)
		if character_stats.is_connected("mana_changed", _on_character_mana_changed):
			character_stats.disconnect("mana_changed", _on_character_mana_changed)
		if character_stats.is_connected("stamina_changed", _on_character_stamina_changed):
			character_stats.disconnect("stamina_changed", _on_character_stamina_changed)
	
	character_stats = stats
	equipment_manager = equipment
	inventory = inv
	
	# Connect to real-time stat change signals
	if character_stats:
		character_stats.connect("health_changed", _on_character_health_changed)
		character_stats.connect("mana_changed", _on_character_mana_changed)
		character_stats.connect("stamina_changed", _on_character_stamina_changed)
		print("CharacterMenu: Connected to character stat signals for real-time updates")
	
	# Refresh stats display if menu is already created
	if stats_panel:
		# Recreate stats display with actual data
		for child in stats_panel.get_children():
			if child is VBoxContainer:
				# Clear existing content and recreate
				for subchild in child.get_children():
					subchild.queue_free()
				create_stats_display(child)
				break
	
	print("CharacterMenu: Connected to character data")

func _on_character_health_changed(current: int, maximum: int):
	"""Update health display in real-time"""
	if health_value_label:
		health_value_label.text = str(current) + "/" + str(maximum)

func _on_character_mana_changed(current: int, maximum: int):
	"""Update mana display in real-time"""
	if mana_value_label:
		mana_value_label.text = str(current) + "/" + str(maximum)

func _on_character_stamina_changed(current: int, maximum: int):
	"""Update stamina display in real-time"""
	if stamina_value_label:
		stamina_value_label.text = str(current) + "/" + str(maximum)

func refresh_stats_display():
	"""Force refresh all stat displays"""
	if character_stats:
		_on_character_health_changed(character_stats.current_hit_points, character_stats.max_hit_points)
		_on_character_mana_changed(character_stats.current_mana_points, character_stats.max_mana_points)
		_on_character_stamina_changed(character_stats.current_stamina_points, character_stats.max_stamina_points)
