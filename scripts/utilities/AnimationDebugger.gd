# AnimationDebugger.gd
# Helper script to debug animations in models

class_name AnimationDebugger
extends Node3D

func debug_animations_in_children(node: Node, depth: int = 0):
	"""Recursively debug all animations in node hierarchy"""
	var indent = "  ".repeat(depth)
	print(indent + "Node: " + node.name + " (" + node.get_class() + ")")
	
	if node is AnimationPlayer:
		var anim_player = node as AnimationPlayer
		print(indent + "  -> AnimationPlayer found!")
		print(indent + "     Available animations:")
		for anim_name in anim_player.get_animation_list():
			print(indent + "       - " + anim_name)
	
	for child in node.get_children():
		debug_animations_in_children(child, depth + 1)

# Function to call from other scripts
static func debug_node_animations(node: Node):
	var debugger = AnimationDebugger.new()
	debugger.debug_animations_in_children(node)
	debugger.queue_free()
