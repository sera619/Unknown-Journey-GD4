extends StaticBody2D

@export_enum("Left", "Right", "Top", "Down") var direction: int
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	match direction:
		0:
			sprite.region_rect = Rect2(128, 480, 32, 32) 
		1:
			sprite.region_rect = Rect2(96, 480, 32, 32) 
		2:
			sprite.region_rect = Rect2(224, 400, 32, 32) 
		3:
			sprite.region_rect = Rect2(160, 480, 32, 32) 
