extends CharacterBody2D
signal enemy_healed(heal_value)
signal enemy_take_damage(damage)

@export_category("Spell Scenes")
@export var spell_scene: PackedScene
@export_category("VFX Scenes")
@export var hit_effect_scene: PackedScene
@export var death_effect_scene: PackedScene
@export var heal_effect_scene: PackedScene
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
@onready var animSprite=$Sprite2D
@onready var raycasts: Node2D = $RayCasts
@onready var enemy_hud: EnemyHUD = $EnemyHUD
@onready var attack_collider: CollisionShape2D = $WeaponAngle/HurtBox/CollisionShape2D
@onready var hurt_collider: CollisionShape2D = $HitBox/CollisionShape2D
@onready var sound_controller: SoundController = $SoundController
@onready var hit_animplayer: AnimationPlayer = $HitBox/AnimationPlayer

enum CAST_TYPE {
	HEAL,
	DAMAGE
}
var current_cast = CAST_TYPE.DAMAGE
#@export var ATTACK_RANGE:int = 32
# should smaller then MIN_RANGE_TO_TARGET
@export var STOP_RADIUS: int = 128
@export var MIN_RANGE_TO_TARGET:int = 46

@export var SLOW_RADIUS: int = 32


enum {
	WANDER,
	IDLE,
	CHASE,
	ATTACK,
	HEAL,
	HURT,
	DEAD,
	FLEE
}

var state = CHASE
var knockback = Vector2.ZERO
var can_attack: bool = true
var is_infight:bool = false
var old_position = Vector2.ZERO
var heal_charges: int = 2
var last_target_position:Vector2 = Vector2.ZERO
var spell_shooted: bool = false
var last_velocity: = Vector2.ZERO

func _ready():
	sound_controller._setup_sounds("Skeleton")
	velocity = Vector2.ZERO
	hitbox.connect("area_entered", on_Hitbox_area_entered)
	attack_timer.connect("timeout", attack_timer_timeout)
	hurt_box.connect("area_entered", on_hurtbox_area_entered)
	hurt_box.damage = stats.damage
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
		last_velocity = velocity
		anim_tree.set("parameters/Idle/blend_position", velocity)
		anim_tree.set("parameters/Move/blend_position", velocity)
		anim_tree.set("parameters/Cast/blend_position", velocity)
		anim_tree.set("parameters/Dead/blend_position", velocity)
		anim_tree.set("parameters/Hurt/blend_position", velocity)
		anim_tree.set("parameters/Idle/blend_position", velocity)
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
			if can_attack and heal_charges > 0 and stats.health < floor(stats.max_health/2):
				state = HEAL
			if player_detector.player != null and can_attack:
				last_target_position = player_detector.player.global_position
				state = ATTACK
			seek_player()
			if player_detector.can_see_player():
				state = CHASE
			if wander_controller.get_time_left() == 0:
				update_wander()
				
		WANDER:
			check_collider()
			seek_player()
			if wander_controller.get_time_left() == 0:
				update_wander()
			if can_attack and heal_charges > 0 and stats.health < int(stats.max_health/2):
				state = HEAL
			accelerate_towards_point(wander_controller.target_position, delta)
			if global_position.distance_to(wander_controller.target_position) <= stats.WANDER_TARGET_RANGE:
				update_wander()
		CHASE:
			check_collider()
			chase_state(delta)
		ATTACK:
			var player = player_detector.player
			if player != null:
				can_attack = false
				attack_state(delta)
		HEAL:
			can_attack = false
			heal_state(delta)
		DEAD:
			can_attack = false
			dead_state(delta)
		HURT:
			can_attack = false
			hurt_state(delta)
		FLEE:
			can_attack = false
			flee_state(delta)

	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	move_and_slide()


func dead_state(_delta):
	velocity = Vector2.ZERO
	can_attack = false
	anim_stats.travel("Dead")

func on_hurtbox_area_entered(area):
	if not area.get_parent().name == "Player":
		return
	can_attack = false
	attack_timer.start()
	state = IDLE

func attack_state(_delta):
	anim_stats.travel("Cast")
	can_attack = false
	hurt_box.set_element_type("Ice")
	current_cast = CAST_TYPE.DAMAGE
	attack_timer.start()
	velocity = Vector2.ZERO

func check_collider():
	if not attack_collider.disabled:
		attack_collider.call_deferred("set_disabled", true)
	if hurt_collider.disabled:
		hurt_collider.call_deferred("set_disabled", false)

func chase_state(delta):
	var player = player_detector.player
	if player != null:
		if stats.health >= stats.max_health / 2 and stats.heal_charges >= 0:
			state = HEAL
		var distance = global_position.distance_to(player.global_position)
		if distance >= STOP_RADIUS:
			accelerate_towards_point(player.global_position, delta)
		if distance > MIN_RANGE_TO_TARGET and can_attack == true:
			can_attack = false
			last_target_position = player.global_position
			attack_timer.start(4.0)
			state = ATTACK
		elif distance < MIN_RANGE_TO_TARGET and can_attack == false:
			state = FLEE
		else:
			state = IDLE
	else:
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



func flee_state(_delta):
	var distance = global_position.distance_to(GameManager.player.global_position)
	var tspeed = stats.MAX_SPEED
	var new_vel
	if distance >= STOP_RADIUS:
		if attack_timer.is_stopped():
			can_attack = true
		state = IDLE
	if distance > SLOW_RADIUS:
		tspeed = stats.MAX_SPEED * (SLOW_RADIUS - distance) / (STOP_RADIUS - SLOW_RADIUS)
		var dir = global_position.direction_to(GameManager.player.global_position) * tspeed
		#wdprint(dir.normalized())
		accelerate_towards_point(global_position + dir.normalized(),  _delta)
	
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
		hit_animplayer.play("hit_flash")
		effect.global_position= animSprite.global_position
		effect.global_position.y += animSprite.offset.y
		cs.add_child(effect)
		stats.set_health( stats.health - area.damage)
		emit_signal("enemy_take_damage", area.damage)
		knockback = area.knockback_vector * 115
		print("[!] Enemy: %s gets hitted for %s damage!" % [self.name, area.damage])
		if stats.health <= 0:
			if hit_sound:
				hit_sound.queue_free()
			var death_sound = death_sound_scene.instantiate()
			self.add_child(death_sound)
			var effect2 = death_effect_scene.instantiate()
			#effect2.global_position.y += animSprite.offset.y
			get_tree().current_scene.add_child(effect2)
			effect2.global_position = animSprite.global_position
			state = DEAD
	else:
		return

func heal_enemy():
	if stats.heal_charges >= 0:
		if spell_shooted:
			state = IDLE
		spell_shooted = true
		var heal_effect = heal_effect_scene.instantiate()
		self.add_child(heal_effect)
		heal_effect.global_position = global_position
		stats.heal_charges -= 1
		stats.set_health(stats.health + int(stats.max_health / 2))
	else:
		return


func heal_state(_delta):
	can_attack = false
	current_cast = CAST_TYPE.HEAL
	attack_timer.start()
	velocity = Vector2.ZERO
	anim_stats.travel("Cast")

func hurt_state(_delta):
	can_attack = false
	attack_timer.start()
	velocity = Vector2.ZERO
	anim_stats.travel("Hurt")


func shoot_projectile():
	spell_shooted = true
	var shoot_direction = $WeaponAngle/HurtBox.global_position.direction_to(last_target_position)
	var projectile: EnemyProjectile = spell_scene.instantiate()
	projectile.spell_damage = stats.damage
	projectile.global_position = $WeaponAngle/HurtBox.global_position
	projectile.direction = shoot_direction
	get_tree().current_scene.add_child(projectile)

func _play_cast_sound():
	if current_cast == CAST_TYPE.HEAL:
		return
	sound_controller._play_spell_cast_sound(SkillManager.ELEMENT.ICE)

func _on_cast_animation_finished():
	if spell_shooted:
		spell_shooted = false
	state = IDLE

func _cast_spell():
	if spell_shooted:
		state = IDLE
	spell_shooted = true
	if current_cast == CAST_TYPE.HEAL:
		current_cast = CAST_TYPE.DAMAGE
		var heal_value = int(floor(stats.max_health / 2))
		emit_signal("enemy_healed", heal_value)
		hit_animplayer.play("heal_flash")
		heal_enemy()
	else:
		shoot_projectile()

func _on_hurt_animation_finished():
	state = CHASE

func _on_attack_animation_finished():
	state = IDLE

func _on_dead_animation_finished():
	reward_player()
	kill_enemy()

func attack_timer_timeout():
	can_attack = true

func kill_enemy():
	self.call_deferred("queue_free")
	print("[!] Enemy: %s died!" % self.name)

func reward_player():
	if not GameManager.player or stats.reward_exp == 0:
		return
	GameManager.player.stats.set_exp(GameManager.player.stats.experience + stats.reward_exp)
		

