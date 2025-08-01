# MagicMissileEffects.gd
# Magic Missile visual effects - precise arcane energy with homing trails
# Follows design team's specifications for magical precision energy

class_name MagicMissileEffects
extends SpellEffects

# Effect components  
var cast_glow: MeshInstance3D
var cast_light: OmniLight3D
var fingertip_energy: GPUParticles3D

func _ready():
	setup_missile_effects()

func setup_missile_effects():
	"""Initialize magic missile casting effects"""
	
	# Fingertip energy glow
	cast_glow = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.08  # Small precise energy point
	cast_glow.mesh = sphere_mesh
	cast_glow.material_override = create_spell_material(ARCANE_PRIMARY, 4.0)
	cast_glow.scale = Vector3.ZERO  # Start hidden
	add_child(cast_glow)
	
	# Blue energy light
	cast_light = OmniLight3D.new()
	cast_light.light_color = ARCANE_PRIMARY  # Blue
	cast_light.light_energy = 0.0  # Start off
	cast_light.omni_range = 2.0  # Smaller range for precise effect
	add_child(cast_light)
	
	# Crackling energy particles
	fingertip_energy = create_performance_particles(15, 1.0)
	var energy_material = fingertip_energy.process_material as ParticleProcessMaterial
	
	# Configure crackling energy effect
	energy_material.direction = Vector3(0, 0, -1)  # Forward from fingertip
	energy_material.spread = 15.0  # Tight spread for precision
	energy_material.initial_velocity_min = 0.5
	energy_material.initial_velocity_max = 1.5
	energy_material.scale_min = 0.02
	energy_material.scale_max = 0.05
	energy_material.gravity = Vector3(0, 0, 0)  # No gravity for energy
	
	# Arcane energy colors - blue to purple
	var energy_gradient = Gradient.new()
	energy_gradient.add_point(0.0, ARCANE_PRIMARY)    # Blue
	energy_gradient.add_point(0.7, ARCANE_SECONDARY)  # Purple
	energy_gradient.add_point(1.0, Color(ARCANE_SECONDARY.r, ARCANE_SECONDARY.g, ARCANE_SECONDARY.b, 0.0))
	var energy_gradient_texture = GradientTexture1D.new()
	energy_gradient_texture.gradient = energy_gradient
	energy_material.color_ramp = energy_gradient_texture
	
	add_child(fingertip_energy)

func play_casting_effect(cast_duration: float = 0.8):
	"""Play precise energy buildup at fingertip"""
	print("MagicMissileEffects: Playing casting effect for ", cast_duration, " seconds")
	
	# Growing energy point at fingertip
	var glow_tween = create_tween()
	glow_tween.set_parallel(true)
	glow_tween.tween_property(cast_glow, "scale", Vector3(0.6, 0.6, 0.6), cast_duration)
	
	# Crackling light buildup
	var light_tween = create_tween()
	light_tween.tween_property(cast_light, "light_energy", 3.0, cast_duration * 0.8)
	
	# Start crackling energy particles
	fingertip_energy.emitting = true
	
	# Pulsing intensity for energy buildup feel
	var pulse_tween = create_tween()
	pulse_tween.set_loops(int(cast_duration * 4))  # 4 pulses per second
	pulse_tween.tween_property(cast_light, "light_energy", 2.0, 0.125)
	pulse_tween.tween_property(cast_light, "light_energy", 3.5, 0.125)

func create_missile_projectile() -> Node3D:
	"""Create precision energy dart projectile"""
	var missile_container = Node3D.new()
	
	# Main energy dart (capsule shape for directionality)
	var missile_dart = MeshInstance3D.new()
	var capsule_mesh = CapsuleMesh.new()
	capsule_mesh.radius = 0.06  # Thin and precise
	capsule_mesh.height = 0.4   # Longer for dart-like appearance
	missile_dart.mesh = capsule_mesh
	missile_dart.material_override = create_spell_material(ARCANE_PRIMARY, 5.0)
	missile_container.add_child(missile_dart)
	
	# Energy trail particles following missile
	var trail_particles = create_performance_particles(8, 0.6)  # Minimal for performance
	var trail_material = trail_particles.process_material as ParticleProcessMaterial
	
	# Configure precise energy trail
	trail_material.direction = Vector3(0, 0, 1)  # Behind missile direction
	trail_material.spread = 5.0  # Very tight trail
	trail_material.initial_velocity_min = 1.0
	trail_material.initial_velocity_max = 2.0
	trail_material.scale_min = 0.03
	trail_material.scale_max = 0.08
	trail_material.gravity = Vector3(0, 0, 0)  # No gravity for energy
	
	# Blue energy trail that fades
	var trail_gradient = Gradient.new()
	trail_gradient.add_point(0.0, Color(ARCANE_PRIMARY.r, ARCANE_PRIMARY.g, ARCANE_PRIMARY.b, 1.0))
	trail_gradient.add_point(1.0, Color(ARCANE_PRIMARY.r, ARCANE_PRIMARY.g, ARCANE_PRIMARY.b, 0.0))
	var trail_gradient_texture = GradientTexture1D.new()
	trail_gradient_texture.gradient = trail_gradient
	trail_material.color_ramp = trail_gradient_texture
	
	trail_particles.emitting = true
	missile_container.add_child(trail_particles)
	
	# Small precise light on missile
	var missile_light = OmniLight3D.new()
	missile_light.light_color = ARCANE_PRIMARY
	missile_light.light_energy = 2.0
	missile_light.omni_range = 1.5  # Small precise light
	missile_container.add_child(missile_light)
	
	print("MagicMissileEffects: Created missile projectile")
	return missile_container

func create_impact_effect(impact_position: Vector3, target: Node3D = null):
	"""Create precise blue energy burst on impact"""
	print("MagicMissileEffects: Creating impact at ", impact_position)
	
	# Get scene tree safely
	var scene_tree = Engine.get_main_loop() as SceneTree
	if not scene_tree or not scene_tree.current_scene:
		print("MagicMissileEffects: ERROR - No scene tree available for impact")
		return
	
	# Small precise energy burst
	var impact_sphere = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.3  # Smaller than fireball for precision
	impact_sphere.mesh = sphere_mesh
	impact_sphere.material_override = create_spell_material(IMPACT_FLASH, 6.0)
	impact_sphere.position = impact_position
	
	scene_tree.current_scene.add_child(impact_sphere)
	
	# Quick precise flash effect
	var impact_tween = create_tween()
	impact_tween.set_parallel(true)
	impact_tween.tween_property(impact_sphere, "scale", Vector3(2.0, 2.0, 2.0), 0.15)
	impact_tween.tween_property(impact_sphere, "modulate", Color.TRANSPARENT, 0.15)
	
	# Target highlight effect if we hit an enemy
	if target:
		highlight_target(target)
	
	# Small energy burst particles
	var burst_particles = create_performance_particles(20, 1.0)
	burst_particles.explosiveness = 1.0  # All at once
	burst_particles.position = impact_position
	
	var burst_material = burst_particles.process_material as ParticleProcessMaterial
	burst_material.direction = Vector3(0, 1, 0)
	burst_material.spread = 30.0  # Moderate spread
	burst_material.initial_velocity_min = 3.0
	burst_material.initial_velocity_max = 6.0
	burst_material.scale_min = 0.04
	burst_material.scale_max = 0.08
	burst_material.gravity = Vector3(0, -1.0, 0)
	
	# Blue energy burst colors
	var burst_gradient = Gradient.new()
	burst_gradient.add_point(0.0, IMPACT_FLASH)      # White flash
	burst_gradient.add_point(0.4, ARCANE_PRIMARY)    # Blue energy
	burst_gradient.add_point(1.0, ARCANE_SECONDARY)  # Purple fade
	var burst_gradient_texture = GradientTexture1D.new()
	burst_gradient_texture.gradient = burst_gradient
	burst_material.color_ramp = burst_gradient_texture
	
	scene_tree.current_scene.add_child(burst_particles)
	burst_particles.emitting = true
	
	# Subtle screen effects for precision feel (less intense than fireball)
	add_screen_shake(0.1, 1.5)
	add_screen_tint(ARCANE_PRIMARY, 0.2)
	
	# Cleanup effects
	cleanup_effect_after_delay(impact_sphere, 0.2)
	cleanup_effect_after_delay(burst_particles, 1.5)

func highlight_target(target: Node3D):
	"""Brief blue highlight on hit target"""
	if not target:
		return
	
	# Create highlight effect on target
	var highlight = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 1.0
	highlight.mesh = sphere_mesh
	
	# Semi-transparent blue highlight material
	var highlight_material = StandardMaterial3D.new()
	highlight_material.emission_enabled = true
	highlight_material.emission = ARCANE_PRIMARY
	highlight_material.emission_energy = 2.0
	highlight_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	highlight_material.albedo_color = Color(ARCANE_PRIMARY.r, ARCANE_PRIMARY.g, ARCANE_PRIMARY.b, 0.5)
	highlight.material_override = highlight_material
	
	target.add_child(highlight)
	
	# Flash effect
	var highlight_tween = create_tween()
	highlight_tween.tween_property(highlight, "modulate", Color.TRANSPARENT, 0.3)
	
	cleanup_effect_after_delay(highlight, 0.4)
	print("MagicMissileEffects: Target highlighted")

func stop_casting_effects():
	"""Stop missile casting effects"""
	print("MagicMissileEffects: Stopping casting effects")
	
	if fingertip_energy:
		fingertip_energy.emitting = false
	
	# Quick fade out for precision feel
	var fade_tween = create_tween()
	fade_tween.set_parallel(true)
	if cast_glow:
		fade_tween.tween_property(cast_glow, "scale", Vector3.ZERO, 0.15)
	if cast_light:
		fade_tween.tween_property(cast_light, "light_energy", 0.0, 0.15)

func show_target_indicator(target_position: Vector3):
	"""Show subtle target indicator during casting"""
	# Get scene tree safely
	var scene_tree = Engine.get_main_loop() as SceneTree
	if not scene_tree or not scene_tree.current_scene:
		print("MagicMissileEffects: ERROR - No scene tree available for target indicator")
		return null
	
	# Create subtle target highlight
	var indicator = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(0.5, 0.5)
	indicator.mesh = plane_mesh
	
	# Subtle blue target material
	var indicator_material = StandardMaterial3D.new()
	indicator_material.emission_enabled = true
	indicator_material.emission = ARCANE_PRIMARY
	indicator_material.emission_energy = 1.0
	indicator_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	indicator_material.albedo_color = Color(ARCANE_PRIMARY.r, ARCANE_PRIMARY.g, ARCANE_PRIMARY.b, 0.6)
	indicator.material_override = indicator_material
	
	indicator.position = target_position + Vector3(0, 0.1, 0)  # Slightly above ground
	indicator.rotation_degrees = Vector3(-90, 0, 0)  # Flat on ground
	
	scene_tree.current_scene.add_child(indicator)
	
	# Pulsing indicator
	var pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.tween_property(indicator, "modulate", Color(1, 1, 1, 0.3), 0.5)
	pulse_tween.tween_property(indicator, "modulate", Color(1, 1, 1, 1.0), 0.5)
	
	# Return indicator for cleanup
	return indicator
