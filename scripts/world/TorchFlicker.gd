# TorchFlicker.gd
# Enhanced flickering light effect with flame and smoke particle animation

class_name TorchFlicker
extends Node3D

@onready var flame_light: OmniLight3D = $FlameLight
@onready var flame_particles: GPUParticles3D = $FlameParticles
@onready var smoke_particles: GPUParticles3D = $SmokeParticles

var base_energy: float = 1.2
var base_color: Color = Color(1.0, 0.6, 0.2)
var flicker_intensity: float = 0.3
var flicker_speed: float = 2.0

# Particle animation variables
var base_flame_amount: int = 25
var base_smoke_amount: int = 15

func _ready():
	if flame_light:
		base_energy = flame_light.light_energy
		base_color = flame_light.light_color
	
	if flame_particles:
		base_flame_amount = flame_particles.amount
	
	if smoke_particles:
		base_smoke_amount = smoke_particles.amount
	
	start_flickering()

func start_flickering():
	"""Start the atmospheric torch flickering effect with particle animation"""
	while is_inside_tree():
		# Random flicker intensity and duration
		var target_energy = base_energy + randf_range(-flicker_intensity, flicker_intensity)
		var flicker_duration = randf_range(0.1, 0.4)
		
		# Create flicker tween
		var flicker_tween = create_tween()
		flicker_tween.set_parallel(true)
		
		# Animate light energy
		flicker_tween.tween_property(flame_light, "light_energy", target_energy, flicker_duration)
		
		# Slight color variation for realism
		var color_variation = get_flame_color_variation()
		flicker_tween.tween_property(flame_light, "light_color", color_variation, flicker_duration)
		
		# Animate flame particles intensity
		animate_flame_particles(flicker_tween, target_energy, flicker_duration)
		
		# Animate smoke particles (subtly)
		animate_smoke_particles(flicker_tween, target_energy, flicker_duration)
		
		# Wait for flicker to complete plus small pause
		await flicker_tween.finished
		await get_tree().create_timer(randf_range(0.05, 0.2)).timeout

func animate_flame_particles(tween: Tween, light_energy: float, duration: float):
	"""Animate flame particle intensity based on light energy"""
	if not flame_particles:
		return
	
	# Vary particle count with light intensity
	var energy_ratio = light_energy / base_energy
	var target_amount = int(base_flame_amount * energy_ratio)
	target_amount = max(15, min(35, target_amount))  # Clamp between 15-35 particles
	
	tween.tween_property(flame_particles, "amount", target_amount, duration)

func animate_smoke_particles(tween: Tween, light_energy: float, duration: float):
	"""Animate smoke particle subtly - more flame = slightly more smoke"""
	if not smoke_particles:
		return
	
	# Smoke varies less dramatically than flame
	var energy_ratio = light_energy / base_energy
	var target_amount = int(base_smoke_amount * (0.8 + energy_ratio * 0.4))  # Less variation
	target_amount = max(10, min(20, target_amount))  # Clamp between 10-20 particles
	
	tween.tween_property(smoke_particles, "amount", target_amount, duration)

func get_flame_color_variation() -> Color:
	"""Get slight orange/yellow color variations for realistic fire"""
	var variation = randf_range(-0.1, 0.1)
	return Color(
		base_color.r + variation,
		base_color.g + variation * 0.5,
		base_color.b,
		1.0
	)
