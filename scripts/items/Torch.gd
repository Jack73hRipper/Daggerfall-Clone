# Torch.gd
# A pickupable torch item that provides light when carried

class_name Torch
extends BaseItem

# Torch-specific properties
@export var light_intensity: float = 1.0
@export var light_range: float = 10.0
@export var flame_color: Color = Color(1.0, 0.8, 0.4, 1.0)
@export var burn_time: float = 300.0  # 5 minutes of burn time
@export var is_lit: bool = false

# References
@onready var torch_light: OmniLight3D = $TorchLight
@onready var flame_particles: GPUParticles3D = $FlameParticles
@onready var torch_mesh: Node3D = $TorchMesh

# Burn state
var remaining_burn_time: float = 0.0
var is_burning_out: bool = false

# Signals
signal torch_lit()
signal torch_extinguished()
signal torch_burned_out()

func _ready() -> void:
	# Set torch-specific properties BEFORE calling super._ready()
	item_name = "Metal Torch"
	item_weight = 2.0
	item_value = 10
	item_description = "A sturdy metal torch that can provide light in dark places."
	
	super._ready()
	
	# Initialize torch state
	remaining_burn_time = burn_time
	
	# Set up torch light
	if torch_light:
		torch_light.light_energy = light_intensity
		torch_light.omni_range = light_range
		torch_light.light_color = flame_color
		torch_light.visible = is_lit
	
	# Set up flame particles
	if flame_particles:
		flame_particles.emitting = is_lit
	
	print("Torch created - Lit: ", is_lit, " Burn time: ", remaining_burn_time)

func _process(delta: float) -> void:
	if is_lit and not is_burning_out:
		# Consume burn time
		remaining_burn_time -= delta
		
		# Check if torch is burning out
		if remaining_burn_time <= 0.0:
			burn_out()
		elif remaining_burn_time <= 30.0:  # Last 30 seconds - start flickering
			start_flickering()

func light_torch() -> bool:
	"""Light the torch if it has fuel remaining"""
	if is_lit or remaining_burn_time <= 0.0:
		return false
	
	is_lit = true
	
	# Enable light and particles
	if torch_light:
		torch_light.visible = true
	if flame_particles:
		flame_particles.emitting = true
	
	torch_lit.emit()
	print("Torch lit! Remaining burn time: ", remaining_burn_time)
	return true

func extinguish_torch() -> bool:
	"""Extinguish the torch manually"""
	if not is_lit:
		return false
	
	is_lit = false
	is_burning_out = false
	
	# Disable light and particles
	if torch_light:
		torch_light.visible = false
	if flame_particles:
		flame_particles.emitting = false
	
	torch_extinguished.emit()
	print("Torch extinguished")
	return true

func burn_out() -> void:
	"""Torch burns out completely"""
	remaining_burn_time = 0.0
	is_burning_out = true
	extinguish_torch()
	
	torch_burned_out.emit()
	print("Torch burned out!")

func start_flickering() -> void:
	"""Start flickering effect when torch is nearly out"""
	if torch_light:
		# Create a simple flickering effect
		var flicker_intensity = light_intensity * (0.7 + randf() * 0.3)
		torch_light.light_energy = flicker_intensity

func get_burn_time_percentage() -> float:
	"""Get remaining burn time as percentage (0.0 to 1.0)"""
	return remaining_burn_time / burn_time

func refuel_torch(additional_time: float = 0.0) -> void:
	"""Add fuel to the torch (for future upgrade system)"""
	if additional_time <= 0.0:
		additional_time = burn_time
	
	remaining_burn_time = min(remaining_burn_time + additional_time, burn_time)
	is_burning_out = false
	print("Torch refueled! New burn time: ", remaining_burn_time)

# Override pickup to handle lighting
func pickup_item(player: Node) -> void:
	super.pickup_item(player)
	
	# If player has a way to light torches automatically, could do it here
	# For now, let's just make sure the player can interact with it

# Override item info to include torch status
func get_item_info() -> Dictionary:
	var info = super.get_item_info()
	info["is_lit"] = is_lit
	info["burn_time_remaining"] = remaining_burn_time
	info["burn_percentage"] = get_burn_time_percentage()
	info["item_type"] = "torch"  # Add item type for positioning
	return info

func get_torch_info() -> Dictionary:
	"""Get torch-specific information for positioning and interaction"""
	return {
		"item_type": "torch",
		"is_lit": is_lit,
		"burn_time_remaining": remaining_burn_time,
		"light_range": light_range
	}
