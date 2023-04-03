extends Node2D

@export var item_name: String
@export var is_looted: bool
@export var respawn_time: int
@export var full_sprite: Texture
@export var empty_sprite: Texture

@onready var body_sprite: Sprite2D = $Body
@onready var icon: Sprite2D = $Icon
@onready var respawn_timer: Timer = $Timer
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var player_detector: PlayerDetector = $PlayerDetector

func _ready():
	_check_texture()
	respawn_timer.connect("timeout", _respawn)

func _check_texture():
	if is_looted:
		body_sprite.texture = empty_sprite
	else:
		body_sprite.texture = full_sprite

func _loot_item():
	if is_looted:
		return
	is_looted = true
	_check_texture()
	anim_player.stop()
	icon.visible = false
	GameManager.info_box.set_info_text("[center]Du hast\n\n[color=blue]\"%s\"[/color]\n\ngeerntet!" % self.item_name)
	if respawn_time != 0:
		respawn_timer.wait_time = respawn_time
		respawn_timer.start()

func _process(delta):
	if player_detector.can_see_player() and not is_looted:
		if not anim_player.is_playing():
			anim_player.play("loop")
			icon.visible = true
	if is_looted or not player_detector.can_see_player():
		anim_player.stop()
		icon.visible = false
	
	if Input.is_action_just_pressed("interact") and player_detector.can_see_player():
		if not is_looted:
			_loot_item()
		else:
			return

func _respawn():
	is_looted = false
	_check_texture()
