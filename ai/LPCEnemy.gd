extends CharacterBody2D
class_name LPCEnemy


signal enemy_healed(heal_value)
signal enemy_take_damage(damage)

@export_category("Spell Scenes")
@export var spell_scene: PackedScene
@export_category("VFX Scenes")
@export_group("Hit")
@export var hit_effect_scene: PackedScene
@export var hit_shader: ShaderMaterial
@export_group("Death")
@export var death_effect_scene: PackedScene
@export_group("Heal")
@export var heal_effect_scene: PackedScene
@export var heal_shader: ShaderMaterial
@export_group("Cast")
@export var cast_effect_scene: PackedScene
@export var cast_shader: ShaderMaterial
@export_category("SFX Scenes")
@export var hurt_sound_scene: PackedScene
@export var death_sound_scene: PackedScene
@export_category("AI Settings")
@export var flee_ai: Resource
@export var chase_ai: Resource
@export var wander_ai: Resource
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
@onready var attack_collider: CollisionShape2D = $WeaponAngle/HurtBox/CollisionShape2D
@onready var hurt_collider: CollisionShape2D = $HitBox/CollisionShape2D
@onready var sound_controller: SoundController = $SoundController
@onready var hit_animplayer: AnimationPlayer = $HitBox/AnimationPlayer
@onready var flee_timer: Timer = $FleeTimer


var ai_data: AIData = AIData.new()
var move_behaviour: MoveBehaviour
var steering: SteeringData
var last_target_position: Vector2 = Vector2()
var start_position: Vector2 = Vector2()

enum {
	CHASE,
	IDLE,
	WANDER,
	ATTACK,
	HEAL,
	DEAD,
	HURT,
	FLEE
}

var state = IDLE
var can_attack: bool = true
var knockback: Vector2 = Vector2.ZERO
var last_velocity: Vector2 = Vector2.ZERO

func _ready():
	start_position = global_position
	sound_controller._setup_sounds("Skeleton")
	flee_timer.wait_time = stats.TIME_BEFORE_FLEE
	flee_timer.connect("timeout", _on_flee_timer_timeout)
	anim_tree.active = true
	_connect_signals()
	_change_move_behaviour(flee_ai)
	hurt_box.damage = stats.damage
	enemy_hud.visible = false
	pick_random_state([WANDER,IDLE])

func _connect_signals():
	stats.connect("enemy_died", _on_death_state)
	hitbox.connect("area_entered", on_Hitbox_area_entered)
	attack_timer.connect("timeout", _attacktimer_timeout)
	hurt_box.connect("area_entered", on_hurtbox_area_entered)

func _process(delta):
	ai_data.pos = global_position
	ai_data.rotation = rotation
	if steering:
		self.position += steering.linear * delta
		self.rotation += steering.angular * delta
		ai_data.last_steering = steering
		velocity = steering.linear
	elif not steering and not state == WANDER:
		velocity = Vector2.ZERO
		
	if velocity != Vector2.ZERO: 
		hurt_box.knockback_vector = velocity
		last_velocity = velocity
		anim_tree.set("parameters/Move/blend_position", velocity)
		anim_tree.set("parameters/Cast/blend_position", velocity)
		anim_tree.set("parameters/Dead/blend_position", velocity)
		anim_tree.set("parameters/Hurt/blend_position", velocity)
		anim_tree.set("parameters/Heal/blend_position", velocity)
		anim_tree.set("parameters/Idle/blend_position", velocity)
		anim_stats.travel("Move")
	else:
		anim_stats.travel("Idle")
	
	match state:
		IDLE:
			_idle_state(delta)
		CHASE:
			_chase_state(delta)
		DEAD:
			_death_state(delta)
		HURT:
			_hurt_state()
		HEAL:
			_heal_state()
		ATTACK:
			_attack_state(delta)
		WANDER:
			_wander_state(delta)
		FLEE:
			_flee_state(delta)

func _physics_process(delta):
	if knockback != Vector2.ZERO:
		knockback = knockback.move_toward(Vector2.ZERO, stats.FRICTION * delta)
		set_velocity(knockback)
	move_and_slide()

# IDLE
func _idle_state(delta):
	velocity = velocity.move_toward(Vector2.ZERO, stats.FRICTION * delta)
	if _check_heal():
		state = HEAL
	if player_detector.can_see_player():
		enemy_hud.show()
		_change_move_behaviour(chase_ai)
		state = CHASE
	if wander_controller.get_time_left() == 0:
		update_wander()

func pick_random_state(statelist: Array):
	statelist.shuffle()
	return statelist.pop_front()

# WANDER
func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wander_controller.start_wander_timer(randi_range(1, 3))

func _wander_state(delta):
	if wander_controller.get_time_left() == 0:
		update_wander()
	accelerate_towards_point(wander_controller.target_position, delta)
	if global_position.distance_to(wander_controller.target_position) <= stats.WANDER_TARGET_RANGE:
		update_wander()
	if player_detector.can_see_player():
		state = CHASE

func accelerate_towards_point(point, delta):
	var speed: int = 0
	if state == WANDER or state == IDLE:
		speed = stats.WANDER_SPEED
	else:
		speed = stats.MAX_SPEED
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * speed, stats.ACCELERATION * delta)

# CHASING
func _chase_state(_delta):
	var player: Player = null
	if _check_heal():
		state = HEAL
	if player_detector.can_see_player():
		player = player_detector.player
	if player == null: 
		steering = null
		state = IDLE
	steering = move_behaviour._get_steering(ai_data)
	if player != null:
		var distance = global_position.distance_to(start_position)
		if can_attack and not _check_heal():
			can_attack = false
			attack_timer.start()
			last_target_position = player.spell_hitbox.global_position
			state = ATTACK
		if distance > 246:
			steering = null
			player = null
			state = IDLE
	else:
		state = IDLE


func _flee_state(_delta):
	var player: Player = null
	if player_detector.can_see_player():
		player = player_detector.player
	if player == null:
		if attack_timer.is_stopped():
			can_attack = true
		steering = null
		state = WANDER
	if player != null and global_position.distance_to(player.global_position) <= stats.FLEE_RANGE:
		can_attack = false
		steering = move_behaviour._get_steering(ai_data)
	else:
		if attack_timer.is_stopped():
			can_attack = true
		steering = null
		state = IDLE


# ATTACK
func _attack_state(_delta):
	anim_stats.travel("Cast")
	steering = null

func _cast_spell():
	var shoot_direction = $WeaponAngle/HurtBox.global_position.direction_to(last_target_position)
	var projectile: EnemyProjectile = spell_scene.instantiate()
	projectile.spell_damage = stats.damage
	projectile.global_position = $WeaponAngle/HurtBox.global_position
	projectile.direction = shoot_direction
	GameManager.current_world.map_container.add_child(projectile)

func _create_cast_effect():
	var effect = cast_effect_scene.instantiate()
	effect.global_position.y += animSprite.offset.y
	self.add_child(effect)
	animSprite.material = cast_shader
	await get_tree().create_timer(0.6).timeout
	animSprite.material = null

func _play_cast_sound():
	sound_controller._play_spell_cast_sound(SkillManager.ELEMENT.ICE)


# TAKE DAMAGE
func take_damage(area):
	if area.attack_type == PlayerSword.Type.NORMAL and GameManager.player.stats.level > 4:
		GameManager.player.stats.set_energie(GameManager.player.stats.energie + 1)
	stats.take_damage(area.damage)
	knockback = area.knockback_vector * 115
	emit_signal("enemy_take_damage", area.damage)
	_create_hit_effect()
	if stats.health > stats.max_health:
		state = HURT

func _hurt_state():
	anim_stats.travel("Hurt")
	steering = null

func _set_knockback(vector: Vector2):
	knockback = vector * 115

func _create_hit_effect():
	var effect = hit_effect_scene.instantiate()
	effect.global_position.y += animSprite.offset.y
	add_child(effect)
	var sound = hurt_sound_scene.instantiate()
	add_child(sound)
	animSprite.material = hit_shader
	await get_tree().create_timer(0.3).timeout
	animSprite.material = null

func on_Hitbox_area_entered(area):
	if not area.is_in_group("playerSword"):
		return
	take_damage(area)


# HEAL
func _check_heal() -> bool:
	if stats.health <= stats.max_health / 2 and stats.heal_charges > 0 and can_attack:
		return true
	return false 

func _heal_state():
	anim_stats.travel("Heal")
	velocity = Vector2.ZERO
	steering = null

func _cast_heal():
	can_attack = false
	attack_timer.start()
	stats.set_health(stats.health + (stats.max_health /2))
	stats.heal_charges -= 1
	emit_signal("enemy_healed", stats.max_health / 2)
	_create_heal_effect()

func _create_heal_effect():
	var effect = heal_effect_scene.instantiate()
	add_child(effect)
	animSprite.material = heal_shader
	await get_tree().create_timer(0.6).timeout
	animSprite.material = null

# DEATH
func _kill_enemy():
	_reward_player()
	self.call_deferred("queue_free")
	print("[!] Enemy: %s died!" % self.name)

func _death_state(delta):
	anim_stats.travel("Dead")
	if not self.hurt_collider.disabled: 
		self.hurt_collider.call_deferred("set_disabled", true)
	if not self.animSprite.visible:
		self.animSprite.visible = false
	if steering:
		steering = null
	velocity = velocity.move_toward(Vector2.ZERO, stats.FRICTION * delta)

func _reward_player():
	if not GameManager.player or stats.reward_exp == 0:
		return
	GameManager.player.stats.set_exp(GameManager.player.stats.experience + stats.reward_exp)
	if QuestManager.current_quest and QuestManager.current_quest.title == "Bombig":
		var qitem = preload("res://prefab/itemdrops/AshDrop.tscn").instantiate()
		qitem.global_position = self.global_position
		GameManager.current_world.game_map.add_child(qitem)
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


func _create_death_effect():
#	var effect = death_effect_scene.instantiate()
#	add_child(effect)
	var sound = death_sound_scene.instantiate()
	add_child(sound)


# HELPER
func _change_move_behaviour(behaviour: Resource):
	move_behaviour = behaviour.new()


# SIGNALS
func _on_dead_animation_finished():
	_kill_enemy()

func _attacktimer_timeout():
	can_attack = true

func _on_heal_animation_finished():
	attack_timer.start()
	state = IDLE

func _on_cast_animation_finished():
	state = IDLE

func _on_hurt_animation_finished():
	if attack_timer.is_stopped():
		can_attack = true
	state = IDLE

func _on_death_state():
	_create_death_effect()
	state = DEAD

func _on_flee_timer_timeout():
	_change_move_behaviour(flee_ai)
	state = FLEE


func on_hurtbox_area_entered(area):
	if not area.get_parent().name == "Player":
		return
	can_attack = false
	attack_timer.start()
	state = IDLE
