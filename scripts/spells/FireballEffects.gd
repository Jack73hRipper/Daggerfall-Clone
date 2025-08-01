# FireballEffects.gd
# Fireball visual effects implementation following design team's three-stage system
# Stage 1: Casting buildup, Stage 2: Projectile travel, Stage 3: Explosion impact

class_name FireballEffects
extends SpellEffects

# Effect components
var cast_particles: GPUParticles3D
var cast_orb: MeshInstance3D
var cast_light: OmniLight3D

func _ready():
	setup_casting_effects()

func setup_casting_effects():
	"""Initialize casting stage effects"""
	# Casting orb that grows in player's hand
	cast_orb = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.1
	cast_orb.mesh = sphere_mesh
	cast_orb.material_override = create_spell_material(FIRE_PRIMARY, 3.0)
	cast_orb.scale = Vector3.ZERO  # Start hidden
	add_child(cast_orb)
	
	# Orange light for casting glow
	cast_light = OmniLight3D.new()
	cast_light.light_color = FIRE_PRIMARY
	cast_light.light_energy = 0.0  # Start off
	cast_light.omni_range = 3.0
	add_child(cast_light)
	
	# Particle buildup effect
	cast_particles = create_performance_particles(MAX_PARTICLES_CAST, 1.5)
	var particle_material = cast_particles.process_material as ParticleProcessMaterial
	
	# Configure fire particle buildup
	particle_material.direction = Vector3(0.0, 1.0, 0.0)  # Upward spiral
	particle_material.initial_velocity_min = 1.0
	particle_material.initial_velocity_max = 3.0
	particle_material.angular_velocity_min = -180.0
	particle_material.angular_velocity_max = 180.0
	particle_material.gravity = Vector3(0, -1.0, 0)  # Light upward pull
	particle_material.scale_min = 0.03
	particle_material.scale_max = 0.08
	
	# Fire colors - start red, fade to orange
	var gradient = Gradient.new()
	gradient.add_point(0.0, FIRE_SECONDARY)  # Red
	gradient.add_point(1.0, FIRE_PRIMARY)   # Orange
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	particle_material.color_ramp = gradient_texture
	
	add_child(cast_particles)

func play_casting_effect(duration: float = 1.0):
	"""Play Stage 1: Casting buildup effect"""
	print("FireballEffects: Playing casting effect for ", duration, " seconds")
	
	# Growing orb in hand
	var orb_tween = create_tween()
	orb_tween.set_parallel(true)
	orb_tween.tween_property(cast_orb, "scale", Vector3(0.4, 0.4, 0.4), duration)
	
	# Pulsing light buildup
	var light_tween = create_tween()
	light_tween.set_parallel(true)
	light_tween.tween_property(cast_light, "light_energy", 2.5, duration * 0.8)
	
	# Particle spiral buildup
	cast_particles.emitting = true
	var particle_count_tween = create_tween()
	particle_count_tween.tween_method(update_particle_count, 5, MAX_PARTICLES_CAST, duration)
	
	# Audio cue (crackling energy)
	play_casting_audio()

func update_particle_count(count: int):
	"""Gradually increase particle count during buildup"""
	if cast_particles:
		cast_particles.amount = count

func play_casting_audio():
	"""Play casting audio effects"""
	# TODO: Add AudioStreamPlayer3D for crackling energy sound
	print("FireballEffects: Playing crackling energy audio")

func create_projectile_effect() -> Node3D:
	"""Create Stage 2: Projectile travel effect"""
	var projectile_container = Node3D.new()
	
	# Main fireball orb
	var fireball_orb = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.25  # Slightly larger for visibility
	fireball_orb.mesh = sphere_mesh
	fireball_orb.material_override = create_spell_material(FIRE_PRIMARY, 4.0)
	projectile_container.add_child(fireball_orb)
	
	# Trailing particles behind projectile
	var trail_particles = create_performance_particles(MAX_PARTICLES_PROJECTILE, 0.8)
	var trail_material = trail_particles.process_material as ParticleProcessMaterial
	
	# Configure trail effect
	trail_material.direction = Vector3(0, 0, 1)  # Behind projectile
	trail_material.initial_velocity_min = 2.0
	trail_material.initial_velocity_max = 4.0
	trail_material.scale_min = 0.05
	trail_material.scale_max = 0.12
	trail_material.gravity = Vector3(0, -0.5, 0)  # Slight gravity
	
	# Fire trail colors
	var trail_gradient = Gradient.new()
	trail_gradient.add_point(0.0, Color(FIRE_PRIMARY.r, FIRE_PRIMARY.g, FIRE_PRIMARY.b, 1.0))
	trail_gradient.add_point(1.0, Color(FIRE_SECONDARY.r, FIRE_SECONDARY.g, FIRE_SECONDARY.b, 0.0))
	var trail_gradient_texture = GradientTexture1D.new()
	trail_gradient_texture.gradient = trail_gradient
	trail_material.color_ramp = trail_gradient_texture
	
	trail_particles.emitting = true
	projectile_container.add_child(trail_particles)
	
	# Projectile light
	var projectile_light = OmniLight3D.new()
	projectile_light.light_color = FIRE_PRIMARY
	projectile_light.light_energy = 1.5
	projectile_light.omni_range = 2.0
	projectile_container.add_child(projectile_light)
	
	print("FireballEffects: Created projectile effect")
	return projectile_container

func create_explosion_effect(explosion_position: Vector3, radius: float = 3.0):
	"""Create Stage 3: Explosion impact effect"""
	print("FireballEffects: Creating explosion at ", explosion_position)
	
	# Get scene tree safely
	var scene_tree = Engine.get_main_loop() as SceneTree
	if not scene_tree or not scene_tree.current_scene:
		print("FireballEffects: ERROR - No scene tree available for explosion")
		return
	
	# Main explosion sphere that rapidly expands
	var explosion_sphere = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.2  # Start small
	explosion_sphere.mesh = sphere_mesh
	explosion_sphere.material_override = create_spell_material(FIRE_PRIMARY, 5.0)
	explosion_sphere.position = explosion_position
	
	scene_tree.current_scene.add_child(explosion_sphere)
	
	# Explosion animation
	var explosion_tween = create_tween()
	explosion_tween.set_parallel(true)
	
	# Rapid sphere expansion
	var final_scale = Vector3(radius * 2, radius * 2, radius * 2)
	explosion_tween.tween_property(explosion_sphere, "scale", final_scale, 0.4)
	explosion_tween.tween_property(explosion_sphere, "modulate", Color.TRANSPARENT, 0.4)
	
	# Particle burst effect
	var burst_particles = create_performance_particles(MAX_PARTICLES_IMPACT, 2.0)
	burst_particles.explosiveness = 1.0  # All particles at once
	burst_particles.position = explosion_position
	
	var burst_material = burst_particles.process_material as ParticleProcessMaterial
	burst_material.direction = Vector3(0, 1, 0)  # Upward base direction
	burst_material.spread = 45.0  # Wide spread for explosion
	burst_material.initial_velocity_min = 5.0
	burst_material.initial_velocity_max = 12.0
	burst_material.scale_min = 0.1
	burst_material.scale_max = 0.3
	burst_material.gravity = Vector3(0, -5.0, 0)  # Particles fall after explosion
	
	# Explosion particle colors
	var burst_gradient = Gradient.new()
	burst_gradient.add_point(0.0, IMPACT_FLASH)      # White hot center
	burst_gradient.add_point(0.3, FIRE_PRIMARY)     # Orange flames
	burst_gradient.add_point(1.0, FIRE_SECONDARY)   # Red embers
	var burst_gradient_texture = GradientTexture1D.new()
	burst_gradient_texture.gradient = burst_gradient
	burst_material.color_ramp = burst_gradient_texture
	
	scene_tree.current_scene.add_child(burst_particles)
	burst_particles.emitting = true
	
	# Screen effects for impact
	add_screen_shake(0.2, 4.0)
	add_screen_tint(FIRE_PRIMARY, 0.3)
	
	# Cleanup explosion effects
	cleanup_effect_after_delay(explosion_sphere, 0.5)
	cleanup_effect_after_delay(burst_particles, 3.0)
	
	print("FireballEffects: Explosion effect created")

func stop_casting_effects():
	"""Stop all casting effects when spell completes or is interrupted"""
	if cast_particles:
		cast_particles.emitting = false
	
	# Fade out orb and light
	var fade_tween = create_tween()
	fade_tween.set_parallel(true)
	if cast_orb:
		fade_tween.tween_property(cast_orb, "scale", Vector3.ZERO, 0.2)
	if cast_light:
		fade_tween.tween_property(cast_light, "light_energy", 0.0, 0.2)
	
	print("FireballEffects: Stopped casting effects")
