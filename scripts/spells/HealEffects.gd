# HealEffects.gd
# Heal spell visual effects - gentle, restorative aura with upward particles
# Follows design team's specifications for soothing healing magic

class_name HealEffects
extends SpellEffects

# Effect components
var aura_light: OmniLight3D
var heal_particles: GPUParticles3D
var sparkle_particles: GPUParticles3D
var pulse_sphere: MeshInstance3D

func _ready():
	setup_heal_effects()

func setup_heal_effects():
	"""Initialize healing effect components"""
	
	# Gentle pulsing aura light
	aura_light = OmniLight3D.new()
	aura_light.light_color = HEAL_PRIMARY  # Soft green
	aura_light.light_energy = 0.0  # Start off
	aura_light.omni_range = 4.0
	add_child(aura_light)
	
	# Pulsing healing sphere around player
	pulse_sphere = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 1.0
	pulse_sphere.mesh = sphere_mesh
	
	# Semi-transparent healing aura material
	var aura_material = StandardMaterial3D.new()
	aura_material.emission_enabled = true
	aura_material.emission = HEAL_PRIMARY
	aura_material.emission_energy = 1.5
	aura_material.albedo_color = Color(HEAL_PRIMARY.r, HEAL_PRIMARY.g, HEAL_PRIMARY.b, 0.3)
	aura_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	aura_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	pulse_sphere.material_override = aura_material
	
	pulse_sphere.scale = Vector3.ZERO  # Start hidden
	add_child(pulse_sphere)
	
	# Upward healing particles
	heal_particles = create_performance_particles(25, 2.5)
	var heal_material = heal_particles.process_material as ParticleProcessMaterial
	
	# Configure gentle upward flow
	heal_material.direction = Vector3(0, 1, 0)  # Straight up
	heal_material.spread = 20.0  # Slight spread
	heal_material.initial_velocity_min = 1.0
	heal_material.initial_velocity_max = 2.5
	heal_material.scale_min = 0.08
	heal_material.scale_max = 0.15
	heal_material.gravity = Vector3(0, -0.5, 0)  # Light gravity for floating effect
	
	# Healing colors - soft green to golden
	var heal_gradient = Gradient.new()
	heal_gradient.add_point(0.0, HEAL_PRIMARY)    # Soft green
	heal_gradient.add_point(0.7, HEAL_SECONDARY)  # Gold
	heal_gradient.add_point(1.0, Color(HEAL_SECONDARY.r, HEAL_SECONDARY.g, HEAL_SECONDARY.b, 0.0))  # Fade out
	var heal_gradient_texture = GradientTexture1D.new()
	heal_gradient_texture.gradient = heal_gradient
	heal_material.color_ramp = heal_gradient_texture
	
	add_child(heal_particles)
	
	# Completion sparkle particles (initially off)
	sparkle_particles = create_performance_particles(30, 1.0)
	sparkle_particles.explosiveness = 1.0  # Burst effect
	sparkle_particles.emitting = false
	
	var sparkle_material = sparkle_particles.process_material as ParticleProcessMaterial
	sparkle_material.direction = Vector3(0, 1, 0)
	sparkle_material.spread = 60.0  # Wide sparkle spread
	sparkle_material.initial_velocity_min = 2.0
	sparkle_material.initial_velocity_max = 5.0
	sparkle_material.scale_min = 0.05
	sparkle_material.scale_max = 0.1
	sparkle_material.gravity = Vector3(0, -2.0, 0)
	
	# Golden sparkle colors
	var sparkle_gradient = Gradient.new()
	sparkle_gradient.add_point(0.0, IMPACT_FLASH)     # Bright white sparkles
	sparkle_gradient.add_point(0.5, HEAL_SECONDARY)   # Golden
	sparkle_gradient.add_point(1.0, Color(HEAL_SECONDARY.r, HEAL_SECONDARY.g, HEAL_SECONDARY.b, 0.0))
	var sparkle_gradient_texture = GradientTexture1D.new()
	sparkle_gradient_texture.gradient = sparkle_gradient
	sparkle_material.color_ramp = sparkle_gradient_texture
	
	add_child(sparkle_particles)

func play_healing_effect(cast_duration: float = 1.5):
	"""Play gentle healing casting effect with breathing rhythm"""
	print("HealEffects: Playing healing effect for ", cast_duration, " seconds")
	
	# Breathing pulsing light (3 pulses during cast time)
	var pulse_count = 3
	var pulse_duration = cast_duration / pulse_count
	
	var light_tween = create_tween()
	light_tween.set_loops(pulse_count)
	light_tween.tween_property(aura_light, "light_energy", 2.5, pulse_duration * 0.4)
	light_tween.tween_property(aura_light, "light_energy", 1.0, pulse_duration * 0.6)
	
	# Gentle sphere pulsing
	var sphere_tween = create_tween()
	sphere_tween.set_parallel(true)
	sphere_tween.tween_property(pulse_sphere, "scale", Vector3(1.2, 1.2, 1.2), cast_duration * 0.3)
	sphere_tween.set_loops(pulse_count)
	sphere_tween.tween_property(pulse_sphere, "scale", Vector3(1.0, 1.0, 1.0), pulse_duration * 0.5)
	sphere_tween.tween_property(pulse_sphere, "scale", Vector3(1.2, 1.2, 1.2), pulse_duration * 0.5)
	
	# Start upward healing particles
	heal_particles.emitting = true
	
	# Gradual color shift from green to more golden
	var color_tween = create_tween()
	color_tween.tween_method(update_healing_color, 0.0, 1.0, cast_duration)

func update_healing_color(progress: float):
	"""Gradually shift healing color from green to golden during cast"""
	if aura_light:
		var current_color = HEAL_PRIMARY.lerp(HEAL_SECONDARY, progress * 0.5)
		aura_light.light_color = current_color

func show_healing_complete(heal_amount: int, player_position: Vector3):
	"""Show healing completion effects with sparkles and floating numbers"""
	print("HealEffects: Healing complete - ", heal_amount, " HP restored")
	
	# Burst of golden sparkles (with null check)
	if sparkle_particles:
		sparkle_particles.restart()
		sparkle_particles.emitting = true
	
	# Brief intensification of aura
	var completion_tween = create_tween()
	completion_tween.set_parallel(true)
	if aura_light:
		completion_tween.tween_property(aura_light, "light_energy", 4.0, 0.2)
		completion_tween.tween_property(aura_light, "light_energy", 0.0, 0.8)
	
	# Pulse sphere final expansion
	if pulse_sphere:
		completion_tween.tween_property(pulse_sphere, "scale", Vector3(2.0, 2.0, 2.0), 0.3)
		completion_tween.tween_property(pulse_sphere, "modulate", Color.TRANSPARENT, 0.5)
	
	# Show floating healing number
	show_floating_number(heal_amount, player_position + Vector3(0, 2, 0), HEAL_SECONDARY)
	
	# Stop continuous effects
	if heal_particles:
		heal_particles.emitting = false
	
	# Gentle screen tint
	add_screen_tint(HEAL_PRIMARY, 0.4)

func stop_healing_effects():
	"""Stop all healing effects when interrupted"""
	print("HealEffects: Stopping healing effects")
	
	if heal_particles:
		heal_particles.emitting = false
	if sparkle_particles:
		sparkle_particles.emitting = false
	
	# Gentle fade out
	var fade_tween = create_tween()
	fade_tween.set_parallel(true)
	
	if aura_light:
		fade_tween.tween_property(aura_light, "light_energy", 0.0, 0.5)
	if pulse_sphere:
		fade_tween.tween_property(pulse_sphere, "scale", Vector3.ZERO, 0.3)
		fade_tween.tween_property(pulse_sphere, "modulate", Color.TRANSPARENT, 0.5)

func play_healing_audio():
	"""Play soothing healing audio"""
	# TODO: Add AudioStreamPlayer3D for gentle healing sounds
	print("HealEffects: Playing soothing healing audio")
