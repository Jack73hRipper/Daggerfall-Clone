# SpellEffects.gd
# Base class for spell visual effects following design team's specifications
# Provides common functionality for all spell effect systems

class_name SpellEffects
extends Node3D

# Common color palette from design spec
const FIRE_PRIMARY = Color("#FF6B35")      # Orange
const FIRE_SECONDARY = Color("#CC2936")    # Red  
const HEAL_PRIMARY = Color("#7FB069")      # Soft Green
const HEAL_SECONDARY = Color("#FFD23F")    # Gold
const ARCANE_PRIMARY = Color("#4895EF")    # Blue
const ARCANE_SECONDARY = Color("#B084CC")  # Purple
const IMPACT_FLASH = Color("#FFFFFF")      # White impact

# Performance-conscious particle limits
const MAX_PARTICLES_CAST = 30
const MAX_PARTICLES_PROJECTILE = 15
const MAX_PARTICLES_IMPACT = 50

func create_spell_material(base_color: Color, intensity: float = 2.0) -> StandardMaterial3D:
	"""Create consistent emissive material for spell effects"""
	var material = StandardMaterial3D.new()
	material.emission_enabled = true
	material.emission = base_color
	material.emission_energy = intensity
	material.albedo_color = base_color
	material.cull_mode = BaseMaterial3D.CULL_DISABLED  # Visible from all angles
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED  # Always face camera
	return material

func create_performance_particles(max_amount: int = 20, lifetime: float = 1.0) -> GPUParticles3D:
	"""Create performance-optimized particle system"""
	var particles = GPUParticles3D.new()
	particles.amount = max_amount
	particles.lifetime = lifetime
	particles.explosiveness = 0.0  # Continuous emission by default
	
	var material = ParticleProcessMaterial.new()
	# Keep minimal physics for performance
	material.gravity = Vector3(0, -2.0, 0)  # Light gravity
	material.initial_velocity_min = 0.5
	material.initial_velocity_max = 2.0
	material.scale_min = 0.05
	material.scale_max = 0.15
	
	particles.process_material = material
	return particles

func show_floating_number(amount: int, position: Vector3, color: Color):
	"""Show floating damage/healing numbers"""
	# Get scene tree safely
	var scene_tree = Engine.get_main_loop() as SceneTree
	if not scene_tree or not scene_tree.current_scene:
		print("SpellEffects: ERROR - No scene tree available for floating numbers")
		return
	
	# Get camera for screen space conversion
	var camera = scene_tree.current_scene.get_viewport().get_camera_3d()
	if not camera:
		return
	
	# Create floating text label
	var label = Label.new()
	label.text = str(amount)
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 24)
	
	# Add to UI layer
	var ui_layer = scene_tree.get_first_node_in_group("ui_layer")
	if not ui_layer:
		# Create temporary UI layer if none exists
		ui_layer = CanvasLayer.new()
		ui_layer.layer = 100  # Above everything
		scene_tree.current_scene.add_child(ui_layer)
	
	ui_layer.add_child(label)
	
	# Convert 3D position to screen space
	var screen_pos = camera.unproject_position(position)
	label.position = screen_pos - Vector2(label.size.x / 2, 0)  # Center horizontally
	
	# Animate floating and fading
	var tween = create_tween()
	tween.parallel().tween_property(label, "position", screen_pos + Vector2(0, -80), 1.5)
	tween.parallel().tween_property(label, "modulate", Color.TRANSPARENT, 1.5)
	
	# Cleanup
	await tween.finished
	label.queue_free()

func add_screen_shake(duration: float = 0.15, intensity: float = 3.0):
	"""Add camera shake for spell impact feedback"""
	# Get scene tree safely
	var scene_tree = Engine.get_main_loop() as SceneTree
	if not scene_tree or not scene_tree.current_scene:
		print("SpellEffects: ERROR - No scene tree available for screen shake")
		return
	
	var camera = scene_tree.current_scene.get_viewport().get_camera_3d()
	if not camera:
		return
	
	var player = scene_tree.get_first_node_in_group("players")
	if not player or not player.has_method("add_screen_shake"):
		return
	
	player.add_screen_shake(duration, intensity)

func add_screen_tint(color: Color, duration: float = 0.3):
	"""Add brief screen color tint for spell effects"""
	# Get scene tree safely
	var scene_tree = Engine.get_main_loop() as SceneTree
	if not scene_tree or not scene_tree.current_scene:
		print("SpellEffects: ERROR - No scene tree available for screen tint")
		return
	
	# Create temporary color overlay
	var overlay = ColorRect.new()
	overlay.color = Color(color.r, color.g, color.b, 0.3)  # Semi-transparent
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block input
	
	# Add to UI layer
	var ui_layer = scene_tree.get_first_node_in_group("ui_layer")
	if not ui_layer:
		ui_layer = CanvasLayer.new()
		ui_layer.layer = 90  # Below floating text
		scene_tree.current_scene.add_child(ui_layer)
	
	ui_layer.add_child(overlay)
	
	# Set to full screen
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Animate fade in and out
	overlay.modulate = Color.TRANSPARENT
	var tween = create_tween()
	tween.tween_property(overlay, "modulate", Color.WHITE, duration * 0.2)
	tween.tween_property(overlay, "modulate", Color.TRANSPARENT, duration * 0.8)
	
	# Cleanup
	await tween.finished
	overlay.queue_free()

func cleanup_effect_after_delay(node: Node, delay: float):
	"""Utility to cleanup effects after a delay"""
	# Get scene tree safely
	var scene_tree = Engine.get_main_loop() as SceneTree
	if not scene_tree:
		print("SpellEffects: ERROR - No scene tree available for cleanup")
		if is_instance_valid(node):
			node.queue_free()
		return
	
	await scene_tree.create_timer(delay).timeout
	if is_instance_valid(node):
		node.queue_free()
