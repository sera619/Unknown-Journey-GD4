extends CharacterBody2D
class_name Player

@export_category('Player Sprites')
@export var SPRITE_SWORD: Texture2D
@export var SPRITE_NO_SWORD: Texture2D
@export_category('Effect Scenes')
@export var hit_effect_scene: PackedScene
@export var levelup_effect_scene: PackedScene
@export var dash_ghost_screne: PackedScene
@export var heal_effect_scene: PackedScene

enum { 
	MOVE, ATTACK, HEAVY_ATTACK, DASH, HURT, DOUBLE_ATTACK
}
var state = MOVE
var roll_vector = Vector2.LEFT
var dash_vector = Vector2.RIGHT
var knockback = Vector2.ZERO
var is_alive = true
var is_dashing = false
var attackable = true
var combat_stance = false
var can_teleport = true
var can_attack = true

@onready var animPlayer = $AnimationPlayer
@onready var animTree = $AnimationTree
@onready var animState = animTree.get("parameters/playback")
@onready var swordHitbox = $SwordHolder/SwordHitbox
@onready var bodySprite = $BodySprite
@onready var stats: Stats = $Stats
@onready var combat_timer: Timer =$CombatTimer
@onready var hitbx: Area2D = $Hitbox
@onready var hit_timer: Timer = $Hitbox/HitTimer
@onready var hit_box_shape = $Hitbox/CollisionShape2D

var vel = Vector2.ZERO

func _ready():
	GameManager.register_node(self)
	hitbx.connect("area_entered", take_damage)
	combat_timer.connect("timeout", combat_timer_timeout)
	hit_timer.connect("timeout", hit_timer_timeout)
	EventHandler.connect("player_level_up", create_levelup_effect)
	if stats.has_sword:
		set_sprite(1)
	else:
		set_sprite(0)
	velocity = Vector2.ZERO
	animTree.active = true
	if GameManager.camera:
		GameManager.camera.player = self
	swordHitbox.knockback_vector = roll_vector


func _process(_delta):
	pass

func _physics_process(delta):
	if !is_alive:
		return
	match state:
		MOVE:
			move_state(delta)
		ATTACK:
			attack_state(delta)
		HEAVY_ATTACK:
			heavy_attack_state(delta)
		DASH:
			create_dash_trail()
			dash_state(delta)
		HURT:
			hurt_state(delta)
		DOUBLE_ATTACK:
			double_attack_state(delta)

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("move_left", "move_right")
	input_vector.y = Input.get_axis("move_up", "move_down")
	input_vector = input_vector.normalized()
	roll_vector = input_vector
	if knockback != Vector2.ZERO:
		knockback = knockback.move_toward(knockback, stats.FRICTION * delta)
		set_velocity(knockback)
		move_and_slide()
		knockback = Vector2.ZERO
	if input_vector != Vector2.ZERO:
		animTree.set("parameters/Idle/blend_position", input_vector)
		animTree.set("parameters/Move/blend_position", input_vector)
		animTree.set("parameters/Attack/blend_position", input_vector)
		animTree.set("parameters/HeavyAttack/blend_position", input_vector)
		animTree.set("parameters/StickSword/blend_position", input_vector)
		animTree.set("parameters/TakeSword/blend_position", input_vector)
		animTree.set("parameters/SwordIdle/blend_position", input_vector)
		animTree.set("parameters/Hurt/blend_position", input_vector)
		animTree.set("parameters/Run/blend_position", input_vector)
		animTree.set("parameters/CombatMove/blend_position", input_vector)
		animTree.set('parameters/AttackDouble/blend_position', input_vector)
		dash_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		if (stats.speed == stats.RUN_SPEED and not combat_stance) or is_dashing:
			animState.travel("Run")
		elif combat_stance == true:
			stats.set_speed(stats.COMBAT_MOVE_SPEED)
			animState.travel("CombatMove")
		else:
			stats.set_speed(stats.MAX_SPEED)
			animState.travel("Move")
		velocity = velocity.move_toward(input_vector * stats.speed, stats.ACCELERATION * delta)
		move()
	
	else:
		
		velocity = velocity.move_toward(Vector2.ZERO, stats.FRICTION * delta)
		if combat_stance and stats.has_sword and not is_dashing:
			animState.travel("SwordIdle")
		else:
			animState.travel("Idle")
	
	if Input.is_action_just_pressed("dash") and not is_dashing:
		state = DASH
	
	if Input.is_action_just_pressed("attack") and can_attack and stats.has_sword and not is_dashing:
		can_attack = false
		state = ATTACK
	
	elif Input.is_action_just_pressed("double_attack") and can_attack and stats.has_sword and not is_dashing:
		can_attack = false
		state = DOUBLE_ATTACK
	
	if Input.is_action_just_pressed("heavy_attack") and can_attack and stats.has_sword and not is_dashing:
		can_attack = false
		state = HEAVY_ATTACK
	
	if Input.is_action_pressed("run") and not is_dashing:
		can_attack = false
		stats.set_speed(stats.RUN_SPEED)
	else:
		can_attack = true
		stats.set_speed(stats.MAX_SPEED)
	
	if Input.is_action_just_pressed("combatmode") and stats.has_sword and not is_dashing and combat_timer.is_stopped():
		if combat_stance:
			animState.travel("StickSword")
			combat_stance = false
		else:
			animState.travel("TakeSword")
			combat_stance = true
	if Input.is_action_just_pressed("healthpotion") and stats.health < stats.MAX_HEALTH:
		use_health_potion()
	
	if Input.is_action_just_pressed("debug_key"):
		GameManager.save_data()

func move():
	if !is_alive:
		return
	set_velocity(velocity)
	move_and_slide()
	velocity = velocity

func hurt_state(delta):
	if knockback != Vector2.ZERO:
		knockback = knockback.move_toward(Vector2.ZERO, stats.FRICTION * delta)
		set_velocity(knockback)
		move_and_slide()
		animState.travel("Hurt")

func attack_state(_delta):
	velocity = Vector2.ZERO
	combat_stance = true
	combat_timer.start()
	animState.travel("Attack")

func double_attack_state(_delta):
	combat_stance = true
	velocity = Vector2.ZERO
	combat_timer.start()
	animState.travel("AttackDouble")


func heavy_attack_state(_delta):
	combat_stance = true
	velocity = Vector2.ZERO
	combat_timer.start()
	animState.travel("HeavyAttack")

func dash_state(delta):
	is_dashing = true
	velocity = dash_vector * stats.DASH_SPEED
	animState.travel("Run")
	move()
	await (get_tree().create_timer(0.3).timeout)
	is_dashing = false
	velocity = velocity.move_toward(Vector2.ZERO * stats.speed, stats.ACCELERATION * delta)
	state = MOVE

func take_damage(area):
	if not attackable and not area.is_in_group("enemyWeapon"):
		return
	if stats.health > 0:
		stats.set_health(stats.health - area.damage)
		knockback = area.knockback_vector.normalized() * 225
		var effect = hit_effect_scene.instantiate()
		get_tree().current_scene.add_child(effect)
		effect.global_position = self.global_position
		attackable = false
		hit_box_shape.call_deferred("set_disabled", true)
		hit_timer.start(2)
		state = HURT
	else:
		is_alive = false
		EventHandler.emit_signal("player_died")
		GameManager.camera.player = null
		GameManager.player = null
		self.queue_free()

func create_levelup_effect():
	var effect = levelup_effect_scene.instantiate()
	self.add_child(effect)
	effect.global_position = global_position
	GameManager.info_box.set_info_text("Glückwunsch!\nDu hast Level: %s erreicht!" % stats.level)


func use_health_potion():
	if stats.player_inventory['Healthpot'] > 0:
		stats.player_inventory['Healthpot'] -= 1
		EventHandler.emit_signal("player_get_healthpot", stats.player_inventory['Healthpot'])
		stats.set_health(stats.health + 4)
		var heal_effect = heal_effect_scene.instantiate()
		self.add_child(heal_effect)
		heal_effect.global_position = global_position
	else:
		return


func set_sprite(sprite: int):
	match sprite:
		0:
			bodySprite.texture = SPRITE_NO_SWORD
		1:
			bodySprite.texture = SPRITE_SWORD

func create_dash_trail():
	var ghost = dash_ghost_screne.instantiate()
	ghost.global_position = bodySprite.global_position
	ghost.frame = bodySprite.frame
	get_tree().current_scene.add_child(ghost)

func hit_timer_timeout():
	if hit_box_shape.disabled:
		hit_box_shape.call_deferred("set_disabled", false)
	attackable = true

func hurt_animation_finished():
	state = MOVE

func combat_timer_timeout():
	combat_stance = false

func attack_animation_finished():
	can_attack = true
	state = MOVE

func heavy_attack_animation_finished():
	can_attack = true
	state = MOVE

func take_sword_animation_finished():
	state = MOVE

