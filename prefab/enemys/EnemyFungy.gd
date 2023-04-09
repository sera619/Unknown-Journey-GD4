extends CharacterBody2D

@export var hit_effect_scene: PackedScene
@export var death_effect_scene: PackedScene
@export_category("SFX Scenes")
@export var hurt_sound_scene: PackedScene
@export var death_sound_scene: PackedScene
@export_category("Reward Settings")
@export_enum("5%", "10%", "15%", "20%") var reward_chance: int
@export var reward_gold: int
@export var reward_scenes: Array[PackedScene]

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
@onready var animSprite=$Sprite2D
@onready var raycasts: Node2D = $RayCasts
@onready var enemy_hud: EnemyHUD = $EnemyHUD
@onready var aoe_collider: CollisionShape2D =$WeaponAngle/HurtBox/CollisionShape2D2
@onready var attack_collider: CollisionShape2D = $WeaponAngle/HurtBox/CollisionShape2D
@onready var hurt_collider: CollisionShape2D = $HitBox/CollisionShape2D
signal enemy_take_damage(damage)
signal enemy_healed(value)

enum {
	WANDER,
	IDLE,
	CHASE,
	ATTACK,
	HEAL
}

var state = CHASE
var knockback = Vector2.ZERO
var can_attack: bool = true
var is_infight:bool = false
var old_position = Vector2.ZERO
var heal_charges: int = 2
func _ready():
	hitbox.connect("area_entered", on_Hitbox_area_entered)
	attack_timer.connect("timeout", attack_timer_timeout)
	hurt_box.connect("area_entered", on_hurtbox_area_entered)
	hurt_box.damage = stats.damage
	velocity = Vector2.ZERO
	anim_tree.active = true
	enemy_hud.visible = false
	pick_random_state([IDLE, WANDER])
	

func on_Hitbox_area_entered(area):
	if not area.is_in_group("playerSword"):
		return
	take_damage(area)


func _physics_process(delta):
	if knockback != Vector2.ZERO:
		knockback = knockback.move_toward(Vector2.ZERO, stats.FRICTION * delta)
		set_velocity(knockback)
		move_and_slide()
	if velocity != Vector2.ZERO:
		hurt_box.knockback_vector = velocity
		anim_tree.set("parameters/Idle/blend_position", velocity)
		anim_tree.set("parameters/Move/blend_position", velocity)
		anim_tree.set("parameters/Attack/blend_position", velocity)
		anim_tree.set("parameters/SporeAttack/blend_position", velocity)
		anim_tree.set("parameters/Heal/blend_position", velocity)
		anim_stats.travel("Move")
	else:
		anim_stats.travel("Idle")
	if player_detector.can_see_player():
		enemy_hud.visible = true
	else:
		enemy_hud.visible = false
	match state:
		IDLE:
			check_collider()
			velocity = velocity.move_toward(Vector2.ZERO, stats.FRICTION * delta)
			seek_player()
			if wander_controller.get_time_left() == 0:
				update_wander()
			if can_attack and heal_charges > 0 and stats.health < int(stats.max_health/2):
				state = HEAL
			if can_attack and player_detector.player != null:
				state = ATTACK
			if player_detector.can_see_player():
				state = CHASE
				
		WANDER:
			check_collider()
			seek_player()
			if wander_controller.get_time_left() == 0:
				update_wander()
			if can_attack and heal_charges > 0 and stats.health < stats.max_health / 2:
				state = HEAL
			accelerate_towards_point(wander_controller.target_position, delta)
			if global_position.distance_to(wander_controller.target_position) <= stats.WANDER_TARGET_RANGE:
				update_wander()
		CHASE:
			check_collider()
			var player = player_detector.player
			if player != null:
				if global_position.distance_to(player.global_position) <= stats.MIN_RANGE or global_position.distance_to(player.global_position) >= stats.MAX_RANGE:
					accelerate_towards_point(player.global_position, delta)
				else:
					if can_attack and heal_charges > 0 and stats.health < int(stats.max_health/2):
						state = HEAL
					elif can_attack:
						state = ATTACK
					else:
						state = IDLE
			else:
				state = IDLE
		ATTACK:
			var player = player_detector.player
			if player != null and can_attack:
				#hurt_box.set_element_type("Poison")
				attack_state(delta)
			else:
				state = IDLE
		HEAL:
			heal_state(delta)
		
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	move_and_slide()

func attack_timer_timeout():
	can_attack = true

func on_hurtbox_area_entered(area):
	if not area.get_parent().name == "Player":
		return
	can_attack = false
	attack_timer.start()
	state = IDLE

func attack_state(_delta):
	anim_stats.travel("SporeAttack")
	hurt_box.set_element_type("Poison")
	velocity = Vector2.ZERO
	can_attack = false
	attack_timer.start()


func check_collider():
	if not aoe_collider.disabled:
		aoe_collider.call_deferred("set_disabled", true)
	if not attack_collider.disabled:
		attack_collider.call_deferred("set_disabled", true)
	if hurt_collider.disabled:
		hurt_collider.call_deferred("set_disabled", false)

func _on_attack_animation_finished():
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
		return

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
		emit_signal("enemy_take_damage", area.damage)
		knockback = area.knockback_vector * 115
		print("[!] Enemy: %s get hit for %s damage!" % [self.name, area.damage])
		if stats.health <= 0:
			var death_sound = death_sound_scene.instantiate()
			get_tree().current_scene.add_child(death_sound)
			var effect2 = death_effect_scene.instantiate()
			#effect2.global_position.y += animSprite.offset.y
			effect2.connect("effect_finished", kill_enemy)
			get_tree().current_scene.add_child(effect2)
			effect2.global_position = animSprite.global_position
			self.visible = false
			reward_player()
		
	else:
		return

func heal_enemy():
	if heal_charges >= 0:
		heal_charges -= 1
		var heal_value = int(floor(float(stats.max_health /2) ))
		stats.set_health(stats.health + heal_value)
		self.emit_signal("enemy_healed", heal_value)

func heal_state(_delta):
	can_attack = false
	attack_timer.start()
	velocity = Vector2.ZERO
	anim_stats.travel("Heal")
	

func _on_heal_animation_finished():
	state = IDLE

func kill_enemy():
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


