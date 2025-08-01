# Quick test script to check model structure
# Run this as a temporary main scene to debug the model structure

extends Node3D

func _ready():
	print("=== TESTING CHARACTER MODEL STRUCTURE ===")
	
	# Load the warrior model
	var warrior_scene = preload("res://assets/3d/RPG Characters - Nov 2020/glTF/Warrior.gltf")
	var warrior_instance = warrior_scene.instantiate()
	add_child(warrior_instance)
	
	print("Warrior model structure:")
	debug_print_node_structure(warrior_instance, 0)
	
	# Look for AnimationPlayer
	var anim_player = find_animation_player(warrior_instance)
	if anim_player:
		print("Found AnimationPlayer with animations:")
		for anim in anim_player.get_animation_list():
			print("  - ", anim)
	else:
		print("No AnimationPlayer found!")

func debug_print_node_structure(node: Node, depth: int) -> void:
	var indent = ""
	for i in depth:
		indent += "  "
	print(indent, node.name, " (", node.get_class(), ")")
	for child in node.get_children():
		debug_print_node_structure(child, depth + 1)

func find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var result = find_animation_player(child)
		if result:
			return result
	return null
