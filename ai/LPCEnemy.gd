extends CharacterBody2D
class_name LPCEnemy


signal enemy_healed(heal_value)
signal enemy_take_damage(damage)

@export_category("Spell Scenes")
@export var spell_scene: PackedScene
@export_category("VFX Scenes")
@export var hit_effect_scene: PackedScene
@export var hit_efect_over: PackedScene
@export var death_effect_scene: PackedScene
@export var heal_effect_scene: PackedScene
@export var heal_effect_overlay: PackedScene
@export_category("SFX Scenes")
@export var hurt_sound_scene: PackedScene
@export var death_sound_scene: PackedScene
@export_category("AI Settings")
@export var flee_ai: Resource
@export var chase_ai: Resource
@export var wander_ai: Resource

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

var ai_data: AIData = AIData.new()
var move_behaviour: MoveBehaviour
var steering: SteeringData
var last_target_position: Vector2 = Vector2()

enum {
	CHASE,
	IDLE,
	WANDER,
	ATTACK,
	HEAL,
	DEAD,
	HURT
}

var state = IDLE
var can_attack: bool = true
var knockback: Vector2 = Vector2.ZERO
var last_velocity: Vector2 = Vector2.ZERO

func _ready():
	sound_controller._setup_sounds("Skeleton")
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
		speed = stats.MAX_SPEED
	else:
		speed = stats.WANDER_SPEED
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
	if can_attack and not _check_heal():
		can_attack = false
		attack_timer.start()
		last_target_position = player.global_position
		state = ATTACK

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
	get_tree().current_scene.add_child(projectile)

func _play_cast_sound():
	sound_controller._play_spell_cast_sound(SkillManager.ELEMENT.ICE)


# TAKE DAMAGE
func take_damage(area):
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
	if stats.health <= 0:
		return
	var effect = hit_effect_scene.instantiate()
	effect.global_position.y += animSprite.offset.y
	var overlay = hit_efect_over.instantiate()
	overlay.frame = animSprite.frame
	overlay.offset = animSprite.offset
	overlay.transform = animSprite.transform
	self.add_child(overlay)
	self.move_child(overlay, animSprite.get_index()+1)
	add_child(effect)
	var sound = hurt_sound_scene.instantiate()
	add_child(sound)

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
	var overlay = heal_effect_overlay.instantiate()
	overlay.frame = animSprite.frame
	overlay.offset = animSprite.offset
	overlay.transform = animSprite.transform
	self.add_child(overlay)
	self.move_child(overlay, animSprite.get_index()+1)


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

func on_hurtbox_area_entered(area):
	if not area.get_parent().name == "Player":
		return
	can_attack = false
	attack_timer.start()
	state = IDLE
