# BatEnemy.gd
# Flying enemy with special movement patterns

extends BaseEnemy

var hover_height: float = 2.5
var bob_amplitude: float = 0.3
var bob_speed: float = 2.0
var time_elapsed: float = 0.0

func _ready():
	super._ready()
	# Bat spawns are already positioned at correct height by dungeon generator
	# Update hover_height to match current spawn position
	hover_height = global_position.y

func process_chase(_delta):
	"""Override chase behavior for flying movement"""
	if not player:
		current_state = AIState.IDLE
		return
	
	time_elapsed += _delta
	
	# Play flying animation
	play_animation("fly")
	
	# Calculate direction to player but maintain hover height
	var target_position = player.global_position
	target_position.y = hover_height  # Use absolute height, not relative
	
	var direction = (target_position - global_position).normalized()
	
	# Add bobbing motion
	var bob_offset = sin(time_elapsed * bob_speed) * bob_amplitude
	direction.y += bob_offset * 0.1
	
	# Set velocity directly for flying movement
	velocity.x = direction.x * move_speed
	velocity.y = direction.y * move_speed * 0.5  # Slower vertical movement
	velocity.z = direction.z * move_speed
	
	# Look at player with smooth rotation and model-specific offset  
	if direction.length() > 0.1:
		var target_rotation = atan2(direction.x, direction.z)
		# Use the same rotation offset system as BaseEnemy
		target_rotation += get_model_rotation_offset()
		rotation.y = lerp_angle(rotation.y, target_rotation, 5.0 * _delta)

func process_idle(_delta):
	"""Override idle to include hovering motion"""
	time_elapsed += _delta
	
	# Stop horizontal movement but maintain vertical bobbing
	velocity.x = 0
	velocity.z = 0
	
	# Play idle flying animation
	play_animation("idle")
	
	# Gentle bobbing when idle
	var bob_offset = sin(time_elapsed * bob_speed * 0.5) * bob_amplitude * 0.3
	velocity.y = bob_offset
