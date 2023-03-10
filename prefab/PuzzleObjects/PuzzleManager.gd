extends Node
class_name PuzzleManager

@export var puzzle_container_path: NodePath

var puzzle_container
var puzzle_size: int = 0
var counter: int = 0
var counted_ids:= []

func _ready():
	puzzle_container = get_node(puzzle_container_path)
	puzzle_size = puzzle_container.get_child_count()
	EventHandler.connect("puzzle_activated", count_puzzle_up)
	EventHandler.connect("puzzle_deactivated", count_puzzle_down)


func count_puzzle_up(id):
	if id not in counted_ids:
		print("[!] Puzzle: puzzle piece: %s activated!" % id) 
		counted_ids.append(id)
		if counted_ids.size() == puzzle_size:
			print("[!] Puzzle: puzzle solved!")
			EventHandler.emit_signal("puzzle_solved")
	else:
		return

func count_puzzle_down(id):
	if id in counted_ids:
		counted_ids.erase(id)
		print("[!] Puzzle: puzzle piece: %s deactivated!" % id)
