extends Node2D

signal puzzle_piece_on(id)
signal puzzle_piece_off(id)

@export_category("Base Setting")
@export var active: bool
@export var id: int
@export_category("Textures")
@export var on_texture: Texture
@export var off_texture: Texture

@onready var body = $Body


func _puzzle_on():
	active = true
	body.texture = on_texture
	emit_signal("puzzle_piece_on", id)
	print("[Puzzle]: %s (id: %s) is on." % [self.name, self.id])


func _puzzle_off():
	active = false
	body.texture = off_texture
	emit_signal("puzzle_piece_off", id)
	print("[Puzzle]: %s (id: %s) is off." % [self.name, self.id])
