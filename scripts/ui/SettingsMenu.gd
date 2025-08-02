extends Control

# Settings Menu Controller
# Placeholder for future settings implementation

@onready var back_button = $CenterContainer/VBoxContainer/BackButton

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	back_button.grab_focus()

func _on_back_pressed():
	"""Return to previous menu"""
	hide_menu()

func show_menu():
	"""Show the settings menu"""
	visible = true
	back_button.grab_focus()
	
	# Animate menu appearance
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.2)

func hide_menu():
	"""Hide the settings menu"""
	# Animate menu disappearance
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.15)
	await tween.finished
	
	visible = false

func _input(event):
	"""Handle input when menu is visible"""
	if not visible:
		return
		
	if event.is_action_pressed("ui_cancel"):
		# ESC key - go back
		_on_back_pressed()
