extends Sprite2D
class_name SpriteEffectOverlay

@export_enum("LPC Enemy", "Player") var char_type: int
@export var character_sprite: Texture
@export var shader_material: ShaderMaterial

@onready var timer: Timer = $Timer

func _ready():
	self.material = shader_material
	timer.connect("timeout", queue_free)
	timer.start(.5)


