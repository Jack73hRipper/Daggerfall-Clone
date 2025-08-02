extends Control

# Escape Menu Controller
# Handles in-game pause menu functionality

# Button references
@onready var resume_button = $CenterContainer/VBoxContainer/MenuButtons/ResumeButton
@onready var inventory_button = $CenterContainer/VBoxContainer/MenuButtons/InventoryButton
@onready var settings_button = $CenterContainer/VBoxContainer/MenuButtons/SettingsButton
@onready var save_game_button = $CenterContainer/VBoxContainer/MenuButtons/SaveGameButton
@onready var main_menu_button = $CenterContainer/VBoxContainer/MenuButtons/MainMenuButton
@onready var quit_button = $CenterContainer/VBoxContainer/MenuButtons/QuitButton

# Animation constants
const HOVER_SCALE = 1.05
const NORMAL_SCALE = 1.0
const ANIMATION_DURATION = 0.15

# Tweens for smooth animations
var button_tweens = {}

# Reference to the character menu (if it exists)
var character_menu = null

func _ready():
	# Connect button signals
	resume_button.pressed.connect(_on_resume_pressed)
	inventory_button.pressed.connect(_on_inventory_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	save_game_button.pressed.connect(_on_save_game_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Setup hover effects for enabled buttons
	_setup_button_hover_effects(resume_button)
	_setup_button_hover_effects(inventory_button)
	_setup_button_hover_effects(main_menu_button)
	_setup_button_hover_effects(quit_button)
	
	# Setup disabled button tooltips
	settings_button.tooltip_text = "Coming Soon - Settings menu in development"
	save_game_button.tooltip_text = "Coming Soon - Save system in development"
	
	# Try to find character menu in the scene tree
	_find_character_menu()
	
	# Ensure proper focus
	resume_button.grab_focus()

func _find_character_menu():
	"""Try to find the CharacterMenu in the scene tree"""
	var ui_layer = get_tree().get_first_node_in_group("ui_layer")
	if ui_layer:
		character_menu = ui_layer.get_node_or_null("CharacterMenu")
	
	# If not found in UI layer, search more broadly
	if not character_menu:
		character_menu = get_tree().get_first_node_in_group("character_menu")
	
	# Last resort: search by name in the current scene
	if not character_menu:
		var current_scene = get_tree().current_scene
		if current_scene:
			character_menu = current_scene.find_child("CharacterMenu", true, false)

func _setup_button_hover_effects(button: Button):
	"""Setup hover and focus effects for a button"""
	if button.disabled:
		return
		
	# Connect hover signals
	button.mouse_entered.connect(_on_button_hover_enter.bind(button))
	button.mouse_exited.connect(_on_button_hover_exit.bind(button))
	button.focus_entered.connect(_on_button_hover_enter.bind(button))
	button.focus_exited.connect(_on_button_hover_exit.bind(button))

func _on_button_hover_enter(button: Button):
	"""Handle button hover enter with smooth scale and color transition"""
	if button.disabled:
		return
		
	# Kill any existing tween for this button
	if button in button_tweens and button_tweens[button]:
		button_tweens[button].kill()
	
	# Create new tween
	var tween = create_tween()
	tween.set_parallel(true)
	button_tweens[button] = tween
	
	# Scale animation
	tween.tween_property(button, "scale", Vector2(HOVER_SCALE, HOVER_SCALE), ANIMATION_DURATION)
	tween.tween_property(button, "modulate", Color(1.1, 1.1, 1.1, 1.0), ANIMATION_DURATION)

func _on_button_hover_exit(button: Button):
	"""Handle button hover exit with smooth return to normal"""
	if button.disabled:
		return
		
	# Kill any existing tween for this button
	if button in button_tweens and button_tweens[button]:
		button_tweens[button].kill()
	
	# Create new tween
	var tween = create_tween()
	tween.set_parallel(true)
	button_tweens[button] = tween
	
	# Return to normal scale and color
	tween.tween_property(button, "scale", Vector2(NORMAL_SCALE, NORMAL_SCALE), ANIMATION_DURATION)
	tween.tween_property(button, "modulate", Color.WHITE, ANIMATION_DURATION)

func _on_resume_pressed():
	"""Resume the game"""
	print("Resuming game...")
	_play_button_press_effect(resume_button)
	
	await get_tree().create_timer(0.1).timeout
	hide_menu()

func _on_inventory_pressed():
	"""Open character and inventory screen"""
	print("Opening Character & Inventory...")
	_play_button_press_effect(inventory_button)
	
	await get_tree().create_timer(0.1).timeout
	
	# Hide escape menu and open character menu
	hide_menu()
	
	if character_menu:
		character_menu.show_menu()
	else:
		print("Character menu not found - falling back to Tab key simulation")
		# Fallback: simulate Tab key press to open character menu
		var input_event = InputEventKey.new()
		input_event.keycode = KEY_TAB
		input_event.pressed = true
		Input.parse_input_event(input_event)

func _on_settings_pressed():
	"""Placeholder for settings (shouldn't be called since button is disabled)"""
	print("Settings - Coming Soon!")

func _on_save_game_pressed():
	"""Placeholder for save game (shouldn't be called since button is disabled)"""
	print("Save Game - Coming Soon!")

func _on_main_menu_pressed():
	"""Return to main menu"""
	print("Returning to Main Menu...")
	_play_button_press_effect(main_menu_button)
	
	await get_tree().create_timer(0.2).timeout
	
	# Unpause the game first
	get_tree().paused = false
	
	# Change to main menu scene
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _on_quit_pressed():
	"""Quit to desktop"""
	print("Quitting to desktop...")
	_play_button_press_effect(quit_button)
	
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()

func _play_button_press_effect(button: Button):
	"""Play a quick press effect on button"""
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Quick scale down and back up
	tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.1)
	tween.tween_property(button, "scale", Vector2(HOVER_SCALE, HOVER_SCALE), 0.1).set_delay(0.1)
	
	# Bright flash
	tween.tween_property(button, "modulate", Color(1.3, 1.3, 1.3, 1.0), 0.1)
	tween.tween_property(button, "modulate", Color.WHITE, 0.1).set_delay(0.1)

func show_menu():
	"""Show the escape menu and pause the game"""
	visible = true
	get_tree().paused = true
	
	# Capture mouse cursor
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# Focus the resume button
	resume_button.grab_focus()
	
	# Animate menu appearance
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.2)

func hide_menu():
	"""Hide the escape menu and unpause the game"""
	# Animate menu disappearance
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	await tween.finished
	
	visible = false
	get_tree().paused = false
	
	# Release mouse cursor back to the game
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	"""Handle input when menu is visible"""
	if not visible:
		return
		
	if event.is_action_pressed("ui_cancel"):
		# ESC key - resume game
		_on_resume_pressed()
	elif event.is_action_pressed("ui_accept"):
		# Enter key - activate focused button
		if resume_button.has_focus():
			_on_resume_pressed()
		elif inventory_button.has_focus():
			_on_inventory_pressed()
		elif main_menu_button.has_focus():
			_on_main_menu_pressed()
		elif quit_button.has_focus():
			_on_quit_pressed()
