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

# Cast Bar Components
var cast_bar_container: Control
var cast_bar_background: ColorRect  # Changed from NinePatchRect to ColorRect
var cast_bar_progress: ProgressBar
var cast_bar_spell_name: Label
var cast_bar_time_label: Label
var cast_bar_interrupt_overlay: ColorRect

# Cast Bar State
var cast_bar_tween: Tween
var is_cast_bar_visible: bool = false

# Reference to character stats
var character_stats: Resource  # Will be CharacterStats when loaded

func _ready():
	print("PlayerHUD _ready() called - HUD is being initialized")
	
	# Add to group for easy access by SpellSystem
	add_to_group("player_hud")
	
	# Set up HUD positioning and style
	setup_hud_layout()
	
	# Set up cast bar
	setup_cast_bar()
	
	# Connect to pause mode so HUD stays visible
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect to viewport size changes for cast bar repositioning
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	
	print("PlayerHUD setup complete")

func _on_viewport_size_changed():
	"""Reposition cast bar when window is resized"""
	position_cast_bar()

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

func setup_cast_bar():
	"""Create cast bar UI elements positioned under crosshair"""
	print("PlayerHUD: Setting up cast bar")
	
	# Create cast bar container
	cast_bar_container = Control.new()
	cast_bar_container.name = "CastBarContainer"
	cast_bar_container.size = Vector2(300, 50)
	cast_bar_container.visible = false
	cast_bar_container.z_index = 100  # Ensure it's on top
	add_child(cast_bar_container)
	
	# Position container under crosshair (will be adjusted in position_cast_bar)
	position_cast_bar()
	
	# Background panel
	cast_bar_background = ColorRect.new()
	cast_bar_background.name = "Background"
	cast_bar_background.size = Vector2(300, 50)
	cast_bar_background.color = Color(0.1, 0.1, 0.1, 0.9)
	cast_bar_container.add_child(cast_bar_background)
	
	# Progress bar container
	var progress_container = Control.new()
	progress_container.name = "ProgressContainer"
	progress_container.position = Vector2(10, 25)
	progress_container.size = Vector2(200, 15)
	cast_bar_container.add_child(progress_container)
	
	# Progress bar
	cast_bar_progress = ProgressBar.new()
	cast_bar_progress.name = "ProgressBar"
	cast_bar_progress.size = Vector2(200, 15)
	cast_bar_progress.min_value = 0.0
	cast_bar_progress.max_value = 100.0
	cast_bar_progress.value = 0.0
	cast_bar_progress.show_percentage = false
	
	# Style the progress bar
	var progress_bg = StyleBoxFlat.new()
	progress_bg.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	cast_bar_progress.add_theme_stylebox_override("background", progress_bg)
	
	var progress_fill = StyleBoxFlat.new()
	progress_fill.bg_color = Color.WHITE  # Will be changed per spell
	cast_bar_progress.add_theme_stylebox_override("fill", progress_fill)
	
	progress_container.add_child(cast_bar_progress)
	
	# Spell name label
	cast_bar_spell_name = Label.new()
	cast_bar_spell_name.name = "SpellName"
	cast_bar_spell_name.position = Vector2(10, 5)
	cast_bar_spell_name.size = Vector2(200, 20)
	cast_bar_spell_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cast_bar_spell_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cast_bar_spell_name.add_theme_font_size_override("font_size", 14)
	cast_bar_spell_name.add_theme_color_override("font_color", Color.WHITE)
	cast_bar_spell_name.text = ""
	cast_bar_container.add_child(cast_bar_spell_name)
	
	# Time remaining label
	cast_bar_time_label = Label.new()
	cast_bar_time_label.name = "TimeLabel"
	cast_bar_time_label.position = Vector2(220, 25)
	cast_bar_time_label.size = Vector2(70, 15)
	cast_bar_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	cast_bar_time_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cast_bar_time_label.add_theme_font_size_override("font_size", 10)
	cast_bar_time_label.add_theme_color_override("font_color", Color.WHITE)
	cast_bar_time_label.text = ""
	cast_bar_container.add_child(cast_bar_time_label)
	
	# Interruption overlay
	cast_bar_interrupt_overlay = ColorRect.new()
	cast_bar_interrupt_overlay.name = "InterruptOverlay"
	cast_bar_interrupt_overlay.size = Vector2(300, 50)
	cast_bar_interrupt_overlay.color = Color(1.0, 0.0, 0.0, 0.0)  # Transparent red initially
	cast_bar_interrupt_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cast_bar_container.add_child(cast_bar_interrupt_overlay)
	
	print("PlayerHUD: Cast bar setup complete")

func position_cast_bar():
	"""Position cast bar under crosshair"""
	if not cast_bar_container:
		return
		
	# Get screen center
	var screen_size = get_viewport().get_visible_rect().size
	var center_x = screen_size.x / 2
	var center_y = screen_size.y / 2
	
	# Position: centered horizontally, 100px below center
	cast_bar_container.position = Vector2(center_x - 150, center_y + 100)

# CAST BAR METHODS

func show_cast_bar(spell_name: String, duration: float):
	"""Display cast bar for spell casting"""
	print("PlayerHUD: show_cast_bar called for ", spell_name, " duration: ", duration)
	
	if is_cast_bar_visible:
		print("PlayerHUD: Hiding previous cast bar")
		hide_cast_bar_immediate()
	
	# Set spell data
	cast_bar_spell_name.text = format_spell_name(spell_name)
	update_cast_bar_colors(spell_name)
	
	# Reset progress
	cast_bar_progress.value = 0.0
	cast_bar_time_label.text = "%.1fs" % duration
	
	# Position and show
	position_cast_bar()
	cast_bar_container.visible = true
	cast_bar_container.modulate = Color.TRANSPARENT
	is_cast_bar_visible = true
	
	print("PlayerHUD: Cast bar positioned at: ", cast_bar_container.position)
	print("PlayerHUD: Cast bar visible: ", cast_bar_container.visible)
	print("PlayerHUD: Cast bar modulate: ", cast_bar_container.modulate)
	
	# Fade in animation (performance optimized)
	if cast_bar_tween:
		cast_bar_tween.kill()
	cast_bar_tween = create_tween()
	cast_bar_tween.tween_property(cast_bar_container, "modulate", Color.WHITE, 0.15)
	
	print("PlayerHUD: Cast bar setup complete")

func update_cast_bar_progress(progress: float, time_remaining: float):
	"""Update cast bar progress (0.0 to 1.0)"""
	if not is_cast_bar_visible:
		return
		
	cast_bar_progress.value = progress * 100.0
	cast_bar_time_label.text = "%.1fs" % time_remaining

func hide_cast_bar():
	"""Hide cast bar with fade out"""
	if not is_cast_bar_visible:
		return
	
	if cast_bar_tween:
		cast_bar_tween.kill()
	cast_bar_tween = create_tween()
	cast_bar_tween.tween_property(cast_bar_container, "modulate", Color.TRANSPARENT, 0.2)
	cast_bar_tween.tween_callback(func(): 
		cast_bar_container.visible = false
		is_cast_bar_visible = false
	)

func hide_cast_bar_immediate():
	"""Hide cast bar immediately without animation"""
	if cast_bar_tween:
		cast_bar_tween.kill()
	cast_bar_container.visible = false
	is_cast_bar_visible = false

func show_cast_interrupt_effect():
	"""Show red flash and shake effect for spell interruption"""
	if not is_cast_bar_visible:
		return
	
	# Red flash overlay
	cast_bar_interrupt_overlay.color = Color(1.0, 0.0, 0.0, 0.6)
	
	# Flash animation
	var flash_tween = create_tween()
	flash_tween.tween_property(cast_bar_interrupt_overlay, "color", Color(1.0, 0.0, 0.0, 0.0), 0.3)
	
	# Shake effect (subtle for performance)
	var original_pos = cast_bar_container.position
	var shake_tween = create_tween()
	shake_tween.parallel().tween_property(cast_bar_container, "position", original_pos + Vector2(3, 0), 0.03)
	shake_tween.parallel().tween_property(cast_bar_container, "position", original_pos + Vector2(-3, 0), 0.06)
	shake_tween.parallel().tween_property(cast_bar_container, "position", original_pos, 0.03)
	
	# Hide after interruption feedback
	await flash_tween.finished
	hide_cast_bar()

func show_cast_success_effect():
	"""Show subtle success feedback before hiding"""
	if not is_cast_bar_visible:
		return
	
	# Subtle green tint
	var success_tween = create_tween()
	success_tween.tween_property(cast_bar_container, "modulate", Color(0.9, 1.0, 0.9), 0.1)
	success_tween.tween_property(cast_bar_container, "modulate", Color.WHITE, 0.1)
	
	await success_tween.finished
	hide_cast_bar()

func format_spell_name(spell_name: String) -> String:
	"""Format spell names for display (remove underscores, etc.)"""
	match spell_name:
		"Magic_Missile":
			return "MAGIC MISSILE"
		"Fireball":
			return "FIREBALL"
		"Heal":
			return "HEAL"
		_:
			return spell_name.replace("_", " ").to_upper()

func update_cast_bar_colors(spell_name: String):
	"""Update cast bar colors based on spell type"""
	var colors = get_spell_colors(spell_name)
	
	# Update progress bar fill color
	var progress_fill = StyleBoxFlat.new()
	progress_fill.bg_color = colors.progress
	cast_bar_progress.add_theme_stylebox_override("fill", progress_fill)
	
	# Update background color
	cast_bar_background.color = colors.background
	
	# Update text colors
	cast_bar_spell_name.add_theme_color_override("font_color", colors.text)
	cast_bar_time_label.add_theme_color_override("font_color", colors.text)

func get_spell_colors(spell_name: String) -> Dictionary:
	"""Get color scheme for spell types"""
	match spell_name:
		"Fireball":
			return {
				"progress": Color(1.0, 0.4, 0.0),       # Orange
				"background": Color(0.2, 0.1, 0.0, 0.9), # Dark orange bg
				"text": Color(1.0, 0.9, 0.7)            # Light orange text
			}
		"Heal":
			return {
				"progress": Color(0.2, 0.8, 0.2),       # Green
				"background": Color(0.0, 0.2, 0.0, 0.9), # Dark green bg
				"text": Color(0.8, 1.0, 0.8)            # Light green text
			}
		"Magic_Missile":
			return {
				"progress": Color(0.3, 0.5, 1.0),       # Blue
				"background": Color(0.0, 0.1, 0.2, 0.9), # Dark blue bg
				"text": Color(0.8, 0.9, 1.0)            # Light blue text
			}
		_:
			return {
				"progress": Color.WHITE,
				"background": Color(0.1, 0.1, 0.1, 0.9),
				"text": Color.WHITE
			}
