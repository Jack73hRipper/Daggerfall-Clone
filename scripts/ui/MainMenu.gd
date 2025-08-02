extends Control

# Main Menu Controller
# Handles navigation, button effects, and scene transitions

# Button references
@onready var single_player_button = $CenterContainer/VBoxContainer/MenuButtons/SinglePlayerButton
@onready var multiplayer_button = $CenterContainer/VBoxContainer/MenuButtons/MultiplayerButton
@onready var settings_button = $CenterContainer/VBoxContainer/MenuButtons/SettingsButton
@onready var quit_button = $CenterContainer/VBoxContainer/MenuButtons/QuitButton

# Color scheme constants
const BUTTON_NORMAL_COLOR = Color(0.8, 0.753, 0.651, 1.0)      # Bone white
const BUTTON_HOVER_COLOR = Color(0.8, 0.4, 0.1, 1.0)           # Warm ember orange
const BUTTON_PRESSED_COLOR = Color(1.0, 0.498, 0.2, 1.0)       # Brighter orange
const BUTTON_DISABLED_COLOR = Color(0.291, 0.271, 0.247, 1.0)  # Muted gray

# Hover effect properties
const HOVER_SCALE = 1.05
const NORMAL_SCALE = 1.0
const ANIMATION_DURATION = 0.15

# Tweens for smooth animations
var button_tweens = {}

func _ready():
	# Connect button signals
	single_player_button.pressed.connect(_on_single_player_pressed)
	multiplayer_button.pressed.connect(_on_multiplayer_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Setup hover effects for enabled buttons
	_setup_button_hover_effects(single_player_button)
	_setup_button_hover_effects(quit_button)
	
	# Setup disabled button tooltips (for future use)
	multiplayer_button.tooltip_text = "Coming Soon - Multiplayer features in development"
	settings_button.tooltip_text = "Coming Soon - Settings menu in development"
	
	# Ensure proper focus
	single_player_button.grab_focus()

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
	tween.set_parallel(true)  # Allow multiple simultaneous animations
	button_tweens[button] = tween
	
	# Scale animation
	tween.tween_property(button, "scale", Vector2(HOVER_SCALE, HOVER_SCALE), ANIMATION_DURATION)
	tween.tween_property(button, "modulate", Color(1.1, 1.1, 1.1, 1.0), ANIMATION_DURATION)
	
	# Add subtle glow effect by modulating the button
	var glow_tween = create_tween()
	glow_tween.set_loops()
	glow_tween.tween_property(button, "modulate:a", 0.9, 0.8)
	glow_tween.tween_property(button, "modulate:a", 1.0, 0.8)

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

func _on_single_player_pressed():
	"""Start single player game"""
	print("Starting Single Player Game...")
	
	# Add a brief press effect
	_play_button_press_effect(single_player_button)
	
	# Wait for animation then change scene
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://scenes/main/TestScene.tscn")

func _on_multiplayer_pressed():
	"""Placeholder for multiplayer (shouldn't be called since button is disabled)"""
	print("Multiplayer - Coming Soon!")

func _on_settings_pressed():
	"""Placeholder for settings (shouldn't be called since button is disabled)"""
	print("Settings - Coming Soon!")

func _on_quit_pressed():
	"""Quit the game"""
	print("Quitting game...")
	
	# Add a brief press effect
	_play_button_press_effect(quit_button)
	
	# Wait for animation then quit
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

func _input(event):
	"""Handle keyboard navigation"""
	if event.is_action_pressed("ui_cancel"):
		# ESC key - quit game
		_on_quit_pressed()
	elif event.is_action_pressed("ui_accept"):
		# Enter key - activate focused button
		if single_player_button.has_focus():
			_on_single_player_pressed()
		elif quit_button.has_focus():
			_on_quit_pressed()
