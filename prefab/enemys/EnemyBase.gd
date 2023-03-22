extends CharacterBody2D
class_name EnemyBase
signal enemy_take_damage(damage)

@export_category("Base Settings")
@export var item_name: String
@export_category("VFX Scenes")
@export var hit_effect_scene: PackedScene
@export var death_effect_scene: PackedScene
@export_category("SFX Scenes")
@export var hurt_sound_scene: PackedScene
@export var death_sound_scene: PackedScene
@onready var hitbox: Area2D = $HitBox
@onready var attack_timer: Timer = $Timer
@onready var hurt_box: EnemyWeapon = $WeaponAngle/HurtBox
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var anim_tree:AnimationTree = $AnimationTree
@onready var anim_stats = anim_tree.get("parameters/playback")
@onready var stats: EnemyStats = $EnemyStats
@onready var player_detector: PlayerDetector = $PlayerDetector
@onready var wander_controller: WanderController = $WanderController
@onready var softCollision: = $SoftCollision
@onready var body_sprite: Sprite2D = $Sprite2D
@onready var raycasts: Node2D = $RayCasts
@onready var enemy_hud: EnemyHUD = $EnemyHUD
@onready var debuff_handler: DebuffHandler = $DebuffHandler

enum STATE {
	WANDER,
	IDLE,
	CHASE,
	ATTACK,
	HEAL,
	DEAD,
	CAST_ATTACK
}

var _state: STATE = STATE.CHASE
var knockback = Vector2.ZERO
var can_attack: bool = true
var is_infight:bool = false
var old_position = Vector2.ZERO

func avoid_obstacles() -> Vector2:
	var avoid_vector
	raycasts.rotation = velocity.angle()
	for ray in raycasts.get_children():
		ray.target_position.x = velocity.length() * 1.2
		if ray.is_colliding():
			var obstacle = ray.get_collider()
			avoid_vector = (position + velocity - obstacle.position).normalized() * 12
			return avoid_vector
	return Vector2.ZERO
	
func heal_enemy():
	if stats.heal_charges >= 0:
		stats.heal_charges -= 1
		stats.set_health(stats.health + int(stats.max_health / 2))


func take_damage(area):
	if area.attack_type == PlayerSword.Type.NORMAL and GameManager.player.stats.level > 4:
		GameManager.player.stats.set_energie(GameManager.player.stats.energie + 1)
	if stats.health >= 0:
		var hit_sound = hurt_sound_scene.instantiate()
		self.add_child(hit_sound)
		var effect = hit_effect_scene.instantiate() 
		var cs = get_tree().current_scene
		effect.global_position = body_sprite.global_position
		effect.global_position.y += body_sprite.offset.y
		cs.add_child(effect)
		stats.set_health( stats.health - area.damage)
		emit_signal("enemy_take_damage", area.damage)
		knockback = area.knockback_vector * 115
		print("[!] Enemy: %s gets hitted for %s damage!" % [self.name, area.damage])
		if stats.health <= 0:
			var death_sound = death_sound_scene.instantiate()
			get_tree().current_scene.add_child(death_sound)
			var effect2 = death_effect_scene.instantiate()
			#effect2.global_position.y += animSprite.offset.y
			effect2.connect("effect_finished", kill_enemy)
			get_tree().current_scene.add_child(effect2)
			effect2.global_position = body_sprite.global_position
			self.visible = false
			reward_player()
		
	else:
		return


func _on_ready():
	hitbox.connect("area_entered", on_Hitbox_area_entered)
	attack_timer.connect("timeout", attack_timer_timeout)
	hurt_box.connect("area_entered", on_hurtbox_area_entered)
	hurt_box.damage = stats.damage
	velocity = Vector2.ZERO
	anim_tree.active = true
	enemy_hud.visible = false
	pick_random_state([STATE.IDLE, STATE.WANDER])

func accelerate_towards_point(point, delta):
	var speed: int = 0
	if _state == STATE.WANDER or _state == STATE.IDLE:
		speed = stats.MAX_SPEED
	else:
		speed = stats.WANDER_SPEED
	var direction = global_position.direction_to(point)

	velocity = velocity.move_toward(direction * speed, stats.ACCELERATION * delta)
	velocity += avoid_obstacles()

func set_animation_blends():
	print("You need to set the set_animation_blends Method on Enemy: %s" % get_path())
	return


func seek_player():
	var player: Player = null
	if player_detector.can_see_player():
		player = player_detector.player
		if global_position.distance_to(player.global_position) <= stats.MIN_RANGE or global_position.distance_to(player.global_position) >= stats.MAX_RANGE:
			_state = STATE.CHASE
		else:
			_state = STATE.IDLE
	else:
		if player and player_detector.player == null:
			player = null
		return


func update_wander():
	_state = pick_random_state([STATE.IDLE, STATE.WANDER])
	wander_controller.start_wander_timer(randi_range(1, 3))

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func reward_player():
	if not GameManager.player or stats.reward_exp == 0:
		return
	GameManager.player.stats.set_exp(GameManager.player.stats.experience + stats.reward_exp)

func attack_state(_delta):
	print("You need to set the attack_state Method on Enemy: %s" % get_path())
	return


func kill_enemy():
	self.call_deferred("queue_free")
	print("[!] Enemy: %s died!" % self.name)

func _on_attack_animation_finished():
	_state = STATE.IDLE


func on_hurtbox_area_entered(area):
	if not area.get_parent().name == "Player":
		return
	can_attack = false
	attack_timer.start()
	_state = STATE.IDLE

func _on_heal_animation_finished():
	_state = STATE.IDLE
	
func attack_timer_timeout():
	can_attack = true
	
func on_Hitbox_area_entered(area):
	if not area.is_in_group("playerSword"):
		return
	take_damage(area)
