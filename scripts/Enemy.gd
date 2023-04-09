extends CharacterBody2D
class_name Enemy

signal enemy_take_damage(damage)
signal enemy_died()
signal enemy_healed(heal)

@export var item_name: String
@export_category("Reward Settings")
@export_enum("5%", "10%", "15%", "20%") var reward_chance: int
@export var reward_gold: int
@export var reward_scenes: Array[PackedScene]

@export_category("VFX Scenes")
@export var hit_effect_scene: PackedScene
@export var death_effect_scene: PackedScene
@export_category("SFX Scenes")
@export var hurt_sound_scene: PackedScene
@export var death_sound_scene: PackedScene
@export_category("Shader Materials")
@export var hit_shader: ShaderMaterial
@export var heal_shader: ShaderMaterial 

@onready var hitbox: Area2D = $HitBox
@onready var attack_timer: Timer = $Timer
@onready var hurt_box: Area2D = $WeaponAngle/HurtBox
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var anim_tree:AnimationTree = $AnimationTree
@onready var anim_stats = anim_tree.get("parameters/playback")
@onready var stats: EnemyStats = $EnemyStats
@onready var player_detector: PlayerDetector = $PlayerDetector
@onready var wander_controller: WanderController = $WanderController
@onready var softCollision: = $SoftCollision
@onready var animSprite=$Sprite2D
@onready var raycasts: Node2D = $RayCasts
@onready var enemy_hud: EnemyHUD = $EnemyHUD
@onready var sound_controller: SoundController = $SoundController
@onready var weapon_collider: CollisionShape2D = $WeaponAngle/HurtBox/CollisionShape2D

enum {
	WANDER,
	IDLE,
	CHASE,
	ATTACK
}

var state = CHASE
var knockback = Vector2.ZERO
var can_attack: bool = true
var is_infight:bool = false
var old_position = Vector2.ZERO

func _ready():
	sound_controller._setup_sounds("FlyingEnemy")
	hitbox.connect("area_entered", on_Hitbox_area_entered)
	attack_timer.connect("timeout", attack_timer_timeout)
	hurt_box.connect("area_entered", on_hurtbox_area_entered)
	hurt_box.damage = stats.damage
	animSprite.play("fly")
	velocity = Vector2.ZERO
	enemy_hud.visible = false
	animSprite.material = hit_shader
	pick_random_state([IDLE, WANDER])
	

func on_Hitbox_area_entered(area):
	if not area.is_in_group("playerSword"):
		return
	take_damage(area)


func _physics_process(delta):
	if animSprite.frame == 3:
		sound_controller._play_food_sound()
	if knockback != Vector2.ZERO:
		knockback = knockback.move_toward(Vector2.ZERO, stats.FRICTION * delta)
		set_velocity(knockback)
		move_and_slide()
	if velocity != Vector2.ZERO:
		hurt_box.knockback_vector = velocity
	if player_detector.can_see_player():
		enemy_hud.visible = true
	else:
		enemy_hud.visible = false
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, stats.FRICTION * delta)
			seek_player()
			if wander_controller.get_time_left() == 0:
				update_wander()
			if player_detector.can_see_player() and global_position.distance_to(player_detector.player.global_position) < stats.MAX_RANGE:
				state = CHASE
				
		WANDER:
			seek_player()
			if wander_controller.get_time_left() == 0:
				update_wander()
			accelerate_towards_point(wander_controller.target_position, delta)
			if global_position.distance_to(wander_controller.target_position) <= stats.WANDER_TARGET_RANGE:
				update_wander()
			
		CHASE:
			var player = player_detector.player
			if player != null:
				#if global_position.distance_to(player.global_position) <= stats.MIN_RANGE or
				if global_position.distance_to(player.global_position) >= stats.MAX_RANGE:
					accelerate_towards_point(player.global_position, delta)
				else:
					state = IDLE
				if can_attack:
					state = ATTACK
				else:
					state = IDLE
			else:
				state = IDLE
		ATTACK:
			var player = player_detector.player
			if player != null and can_attack:
				accelerate_towards_point(player.global_position, delta)
	if softCollision.is_colliding():
		knockback += softCollision.get_push_vector() * delta * 400
	move_and_slide()

func attack_timer_timeout():
	can_attack = true
	weapon_collider.call_deferred("set_disabled", false)

func on_hurtbox_area_entered(area):
	if not area.is_in_group("playerHitbox"):
		return
	weapon_collider.call_deferred("set_disabled", true)
	can_attack = false
	attack_timer.start()
	state = IDLE

func seek_player():
	var player: Player = null
	if player_detector.can_see_player():
		player = player_detector.player
		if global_position.distance_to(player.global_position) <= stats.MIN_RANGE or global_position.distance_to(player.global_position) >= stats.MAX_RANGE:
			state = CHASE
		else:
			state = IDLE
	else:
		if player and player_detector.player == null:
			player = null


func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wander_controller.start_wander_timer(randi_range(1, 3))

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func accelerate_towards_point(point, delta):
	var speed: int = 0
	if state == WANDER or state == IDLE:
		speed = stats.MAX_SPEED
	else:
		speed = stats.WANDER_SPEED
	var direction = global_position.direction_to(point)

	velocity = velocity.move_toward(direction * speed, stats.ACCELERATION * delta)
	velocity += avoid_obstacles()
	animSprite.flip_h = velocity.x < 0

func avoid_obstacles():
	var avoid_vector
	raycasts.rotation = velocity.angle()
	for ray in raycasts.get_children():
		ray.target_position.x = velocity.length() * 1.2
		if ray.is_colliding():
			var obstacle = ray.get_collider()
			avoid_vector = (position + velocity - obstacle.position).normalized() * 12
			return avoid_vector
	return Vector2.ZERO
	
func take_damage(area):
	if area.attack_type == PlayerSword.Type.NORMAL and GameManager.player.stats.level > 4:
		GameManager.player.stats.set_energie(GameManager.player.stats.energie + 1)
	if stats.health >= 0:
		var hit_sound = hurt_sound_scene.instantiate()
		self.add_child(hit_sound)
		var effect = hit_effect_scene.instantiate() 
		var cs = get_tree().current_scene
		effect.global_position= animSprite.global_position
		effect.global_position.y += animSprite.offset.y
		cs.add_child(effect)
		stats.set_health( stats.health - area.damage)
		knockback = area.knockback_vector * 105
		EventHandler.emit_signal("statistic_update_dmg_done", area.damage)
		emit_signal("enemy_take_damage", area.damage)
		anim_player.play("Hit")
		if stats.health <= 0:
			var death_sound = death_sound_scene.instantiate()
			self.add_child(death_sound)
			var effect2 = death_effect_scene.instantiate()
			effect2.connect("effect_finished", kill_enemy)
			GameManager.current_world.enemy_container.add_child(effect2)
			effect2.global_position = animSprite.global_position
			self.visible = false
			emit_signal("enemy_died", self)
	else:
		return

func check_quest():
	if QuestManager.current_quest:
		var quest = QuestManager.current_quest
		if quest.object_name == self.item_name:
			quest.add_item()

func kill_enemy():
	check_quest()
	reward_player()
	EventHandler.emit_signal("statistic_update_killed", 1)
	self.call_deferred("queue_free")
	print("[!] Enemy: %s died!" % self.name)

func reward_player():
	if not GameManager.player or stats.reward_exp == 0:
		return
	GameManager.player.stats.set_exp(GameManager.player.stats.experience + stats.reward_exp)
	if _check_player_reward():
		_get_random_reward()


func _get_random_reward():
	var ran = randi_range(0, reward_scenes.size() - 1)
	var reward = reward_scenes[ran].instantiate()
	if reward.name == "CoinDrop":
		reward.amount = reward_gold
	reward.global_position = self.global_position
	GameManager.current_world.game_map.add_child(reward)

func _check_player_reward() -> bool:
	var chance_to_drop = randf_range(0, 100)
	match reward_chance:
		0:
			if chance_to_drop <= 5:
				return true
			else:
				return false
		1: 
			# 10 %
			if chance_to_drop <= 10:
				return true
			else:
				return false
		2:
			# 15 %
			if chance_to_drop <= 15:
				return true
			else:
				return false
		3:
			# 20 %
			if chance_to_drop <= 20:
				return true
			else:
				return false
	return false
