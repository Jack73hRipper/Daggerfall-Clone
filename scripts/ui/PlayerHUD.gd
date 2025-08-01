# PlayerHUD.gd
# Always-visible HUD showing health, mana, and stamina

class_name PlayerHUD
extends Control

# HUD Bar Components
@onready var health_bar: ProgressBar
@onready var mana_bar: ProgressBar  
@onready var stamina_bar: ProgressBar

# Labels for numeric display
@onready var health_label: Label
@onready var mana_label: Label
@onready var stamina_label: Label

# Reference to character stats
var character_stats: Resource  # Will be CharacterStats when loaded

func _ready():
	print("PlayerHUD _ready() called - HUD is being initialized")
	# Set up HUD positioning and style
	setup_hud_layout()
	
	# Connect to pause mode so HUD stays visible
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	print("PlayerHUD setup complete")

func setup_hud_layout():
	"""Create HUD elements programmatically"""
	print("PlayerHUD: Setting up polished HUD layout")
	
	# Set HUD to full screen
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Create container positioned in bottom-left
	var hud_container = VBoxContainer.new()
	hud_container.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	hud_container.position = Vector2(20, -120)  # Offset from bottom-left
	hud_container.size = Vector2(300, 100)
	hud_container.add_theme_constant_override("separation", 5)
	add_child(hud_container)
	
	# Create health bar
	var health_container = create_stat_bar_container("Health", Color.RED)
	health_bar = health_container.get_child(1) as ProgressBar
	health_label = health_container.get_child(2) as Label
	hud_container.add_child(health_container)
	
	# Create mana bar
	var mana_container = create_stat_bar_container("Mana", Color.BLUE)
	mana_bar = mana_container.get_child(1) as ProgressBar
	mana_label = mana_container.get_child(2) as Label
	hud_container.add_child(mana_container)
	
	# Create stamina bar
	var stamina_container = create_stat_bar_container("Stamina", Color.GREEN)
	stamina_bar = stamina_container.get_child(1) as ProgressBar
	stamina_label = stamina_container.get_child(2) as Label
	hud_container.add_child(stamina_container)
	
	# Ensure the HUD is visible
	visible = true
	modulate = Color.WHITE
	
	print("PlayerHUD: Polished HUD layout complete")

func create_stat_bar_container(stat_name: String, bar_color: Color) -> HBoxContainer:
	"""Create a clean stat bar container"""
	var container = HBoxContainer.new()
	container.add_theme_constant_override("separation", 10)
	
	# Stat name label
	var name_label = Label.new()
	name_label.text = stat_name + ":"
	name_label.custom_minimum_size.x = 70
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.add_theme_font_size_override("font_size", 14)
	container.add_child(name_label)
	
	# Progress bar with proper theme setup
	var progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(150, 20)
	progress_bar.show_percentage = false  # We'll show custom text
	
	# Create a custom StyleBox for the progress bar
	var style_bg = StyleBoxFlat.new()
	style_bg.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	progress_bar.add_theme_stylebox_override("background", style_bg)
	
	var style_fill = StyleBoxFlat.new()
	style_fill.bg_color = bar_color
	progress_bar.add_theme_stylebox_override("fill", style_fill)
	
	container.add_child(progress_bar)
	
	# Value label (current/max)
	var value_label = Label.new()
	value_label.custom_minimum_size.x = 60
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.add_theme_color_override("font_color", Color.WHITE)
	value_label.add_theme_font_size_override("font_size", 12)
	container.add_child(value_label)
	
	return container

func create_stat_bar(parent: VBoxContainer, stat_name: String, bar_color: Color, stat_type: String):
	"""Create a stat bar with label"""
	# Container for this stat
	var hbox = HBoxContainer.new()
	parent.add_child(hbox)
	
	# Stat name label
	var name_label = Label.new()
	name_label.text = stat_name + ":"
	name_label.custom_minimum_size.x = 80
	name_label.add_theme_color_override("font_color", Color.WHITE)
	hbox.add_child(name_label)
	
	# Progress bar
	var progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(150, 20)
	progress_bar.add_theme_color_override("fill", bar_color)
	progress_bar.add_theme_color_override("background", Color(0.2, 0.2, 0.2, 0.8))
	hbox.add_child(progress_bar)
	
	# Value label (current/max)
	var value_label = Label.new()
	value_label.custom_minimum_size.x = 60
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.add_theme_color_override("font_color", Color.WHITE)
	hbox.add_child(value_label)
	
	# Store references based on stat type
	match stat_type:
		"health":
			health_bar = progress_bar
			health_label = value_label
		"mana":
			mana_bar = progress_bar
			mana_label = value_label
		"stamina":
			stamina_bar = progress_bar
			stamina_label = value_label

func connect_to_character_stats(stats: Resource):
	"""Connect HUD to character stats for updates"""
	print("PlayerHUD: connect_to_character_stats called with: ", stats)
	
	if character_stats:
		# Disconnect previous signals
		if character_stats.is_connected("health_changed", _on_health_changed):
			character_stats.disconnect("health_changed", _on_health_changed)
		if character_stats.is_connected("mana_changed", _on_mana_changed):
			character_stats.disconnect("mana_changed", _on_mana_changed)
		if character_stats.is_connected("stamina_changed", _on_stamina_changed):
			character_stats.disconnect("stamina_changed", _on_stamina_changed)
	
	character_stats = stats
	
	if character_stats:
		print("PlayerHUD: Connecting signals and updating bars")
		# Connect to stat change signals
		character_stats.connect("health_changed", _on_health_changed)
		character_stats.connect("mana_changed", _on_mana_changed)
		character_stats.connect("stamina_changed", _on_stamina_changed)
		
		# Initial update
		update_all_bars()
		print("PlayerHUD: All bars updated with initial values")
	else:
		print("PlayerHUD: ERROR - No character stats provided!")

func update_all_bars():
	"""Update all HUD bars with current values"""
	if not character_stats:
		return
	
	_on_health_changed(character_stats.current_hit_points, character_stats.max_hit_points)
	_on_mana_changed(character_stats.current_mana_points, character_stats.max_mana_points)
	_on_stamina_changed(character_stats.current_stamina_points, character_stats.max_stamina_points)

func _on_health_changed(current: int, maximum: int):
	"""Update health bar display"""
	print("PlayerHUD: Health changed - ", current, "/", maximum)
	if health_bar and health_label:
		health_bar.max_value = maximum
		health_bar.value = current
		health_label.text = str(current) + "/" + str(maximum)
		
		# Change color based on health percentage
		var health_percent = float(current) / float(maximum)
		var style_fill = StyleBoxFlat.new()
		
		if health_percent <= 0.25:
			style_fill.bg_color = Color.DARK_RED
		elif health_percent <= 0.5:
			style_fill.bg_color = Color.ORANGE_RED
		else:
			style_fill.bg_color = Color.RED
			
		health_bar.add_theme_stylebox_override("fill", style_fill)

func _on_mana_changed(current: int, maximum: int):
	"""Update mana bar display"""
	if mana_bar and mana_label:
		mana_bar.max_value = maximum
		mana_bar.value = current
		mana_label.text = str(current) + "/" + str(maximum)
		
		# Ensure mana bar stays blue
		var style_fill = StyleBoxFlat.new()
		style_fill.bg_color = Color.BLUE
		mana_bar.add_theme_stylebox_override("fill", style_fill)

func _on_stamina_changed(current: int, maximum: int):
	"""Update stamina bar display"""
	if stamina_bar and stamina_label:
		stamina_bar.max_value = maximum
		stamina_bar.value = current
		stamina_label.text = str(current) + "/" + str(maximum)
		
		# Change color based on stamina percentage
		var stamina_percent = float(current) / float(maximum)
		var style_fill = StyleBoxFlat.new()
		
		if stamina_percent <= 0.25:
			style_fill.bg_color = Color.DARK_GREEN
		else:
			style_fill.bg_color = Color.GREEN
			
		stamina_bar.add_theme_stylebox_override("fill", style_fill)

func toggle_hud_visibility(should_show: bool):
	"""Show or hide the HUD"""
	self.visible = should_show

func get_hud_visibility() -> bool:
	"""Check if HUD is visible"""
	return visible
