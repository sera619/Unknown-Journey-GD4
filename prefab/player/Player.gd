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

@export_category("Sound Scenes")
@export var foodstep_a_scene: PackedScene
@export var foodstep_b_scene: PackedScene
@export var hurt_sound_scene: PackedScene
@export var dash_sound_scene: PackedScene
@export var potion_sound_scene: PackedScene

@export_category("Shader Materials")
@export var heal_shader: ShaderMaterial
@export var dmg_shader: ShaderMaterial

enum { 
	MOVE, ATTACK, HEAVY_ATTACK, DASH, HURT, DOUBLE_ATTACK
}
var state = MOVE
var roll_vector: Vector2 = Vector2.LEFT
var dash_vector: Vector2 = Vector2.RIGHT
var knockback: Vector2 = Vector2.ZERO
var attackable: bool = true
var combat_stance: bool = false

var is_alive: bool = true
var is_dashing: bool = false

var dot_count: int = 0
var is_dotted: bool = false
var is_slowed: bool = false
var dot_damage: int = 0

var can_dash: bool = true
var can_teleport: bool = true
var can_attack: bool = true

@onready var animPlayer = $AnimationPlayer
@onready var animTree = $AnimationTree
@onready var animState = animTree.get("parameters/playback")
@onready var swordHitbox:PlayerSword = $SwordHolder/SwordHitbox
@onready var sword_collider: CollisionShape2D = $SwordHolder/SwordHitbox/CollisionShape2D
@onready var sword_heavy_collider: CollisionShape2D = $SwordHolder/SwordHitbox/HeavyShape
@onready var bodySprite = $BodySprite
@onready var stats: Stats = $Stats
@onready var combat_timer: Timer =$CombatTimer
@onready var hitbx: Area2D = $Hitbox
@onready var spell_hitbox: Area2D = $SpellHitBox
@onready var spell_collider: CollisionShape2D = $SpellHitBox/CollisionShape2D
@onready var hit_timer: Timer = $Hitbox/HitTimer
@onready var hit_box_shape = $Hitbox/CollisionShape2D
@onready var dash_timer: Timer = $DashTimer
@onready var dot_timer: Timer = $Hitbox/DotTimer
@onready var debuff_handler: DebuffHandler = $DebuffHandler
@onready var sound_controller: SoundController = $SoundController

var vel = Vector2.ZERO

func _ready():
	GameManager.register_node(self)
	hitbx.connect("area_entered", take_damage)
	spell_hitbox.connect("area_entered", take_damage)
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
	swordHitbox.set_sword_damage(stats.damage)
	sound_controller._setup_sounds("Player")



func _process(_delta):
	G.player = self
	G.player_data.pos = global_position
	G.player_data.rotation = rotation
	G.player_data.last_steering.linear = velocity * stats.MAX_SPEED
	
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
	if not GameManager.interface.dev_console:
		input_vector.x = Input.get_axis("move_left", "move_right")
		input_vector.y = Input.get_axis("move_up", "move_down")
		input_vector = input_vector.normalized()
		roll_vector = input_vector
	if sword_collider.disabled == false:
		sword_collider.call_deferred("set_disabled", true)
	if sword_heavy_collider.disabled == false:
		sword_heavy_collider.call_deferred("set_disabled", true)
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
		if stats.speed == stats.RUN_SPEED and not combat_stance and not is_dashing:
			animState.travel("Run")
		elif stats.speed == stats.MAX_SPEED and not combat_stance and not is_dashing:
			stats.set_speed(stats.MAX_SPEED)
			animState.travel("Move")
		elif combat_stance:
			stats.set_speed(stats.COMBAT_MOVE_SPEED)
			animState.travel("CombatMove")
		if is_slowed :
			stats.set_speed(stats.COMBAT_MOVE_SPEED * 0.75)
		velocity = velocity.move_toward(input_vector * stats.speed, stats.ACCELERATION * delta)
		move()
	
	else:
		
		velocity = velocity.move_toward(Vector2.ZERO, stats.FRICTION * delta)
		if combat_stance and stats.has_sword and not is_dashing:
			animState.travel("SwordIdle")
		else:
			animState.travel("Idle")
	_input_handler(delta)

func _input_handler(_delta):
	if GameManager.interface.dev_console == true:
		return
	
	if Input.is_action_just_pressed("dash") and not is_dashing and stats.level > 1 and can_dash:
		var sound = dash_sound_scene.instantiate()
		self.add_child(sound)
		dash_timer.wait_time = stats.DASH_COOLDOWN
		dash_timer.start()
		can_dash = false
		can_attack = false
		state = DASH
	
	if Input.is_action_just_pressed("attack") and can_attack and stats.has_sword and not is_dashing:
		can_attack = false
		swordHitbox.set_attack_type("Normal")
		state = ATTACK
	
	elif Input.is_action_just_pressed("double_attack") and can_attack and stats.has_sword:
		if stats.level < stats.DOUBLE_ATTACK_CAP:
			return
		if not is_dashing and stats.energie >= stats.DOUBLE_ATTACK_COST:
			can_attack = false
			stats.set_energie(stats.energie - stats.DOUBLE_ATTACK_COST)
			swordHitbox.set_attack_type("Double")
			state = DOUBLE_ATTACK
	
	if Input.is_action_just_pressed("heavy_attack") and can_attack and stats.has_sword and not is_dashing and stats.energie >= stats.HEAVY_ATTACK_COST:
		if stats.level < stats.HEAVY_ATTACK_CAP:
			return
		can_attack = false
		stats.set_energie(stats.energie - stats.HEAVY_ATTACK_COST)
		swordHitbox.set_attack_type("Heavy")
		state = HEAVY_ATTACK
	
	if Input.is_action_pressed("run") and not is_dashing:
		can_attack = false
		stats.set_speed(stats.RUN_SPEED)
	else:
		can_attack = true
		stats.set_speed(stats.MAX_SPEED)
	
	if Input.is_action_just_pressed("combatmode") and stats.has_sword and not is_dashing:
		if not combat_timer.is_stopped():
			return
		if combat_stance:
			animState.travel("StickSword")
			combat_stance = false
		else:
			animState.travel("TakeSword")
			combat_stance = true
				

	if Input.is_action_just_pressed("healthpotion") and stats.health < stats.MAX_HEALTH:
		use_health_potion()
	
	if Input.is_action_just_pressed("debug_key"):
		#debuff_handler.get_debuff_effect(SkillManager.ELEMENT.POISON)
		#EventHandler.emit_signal("player_sleep")
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
	can_attack = true
	velocity = velocity.move_toward(Vector2.ZERO * stats.speed, stats.ACCELERATION * delta)
	state = MOVE

func take_damage(area):
	if not attackable or not area.is_in_group("enemyWeapon"):
		return
	if stats.health >= 0:
		stats.set_health(stats.health - area.damage)
		knockback = area.knockback_vector.normalized() * 225
		var effect = hit_effect_scene.instantiate()
		get_tree().current_scene.add_child(effect)
		effect.global_position = self.global_position
		var sound = hurt_sound_scene.instantiate()
		self.add_child(sound)
		attackable = false
		if stats.has_sword:
			combat_stance = true
		hit_box_shape.call_deferred("set_disabled", true)
		spell_collider.call_deferred("set_disabled", true)
		hit_timer.start(2)
		if not area.attack_element == SkillManager.ELEMENT.NONE:
			is_dotted = true
			self.set_dot(area.get_dot_damage(), area.get_dot_count(), area.attack_element)
		else:
			GameManager.camera.add_trauma(1.2)
		Engine.time_scale = 0.8
		state = HURT


func set_dot(dmg: int, count: int, element):
	debuff_handler.get_debuff_effect(element)
	if element == SkillManager.ELEMENT.ICE:
		is_slowed = true
		self.stats.set_speed(self.stats.COMBAT_MOVE_SPEED * 0.8)
	else:
		self.dot_damage = dmg
	self.dot_count = count
	self.dot_timer.wait_time = 1
	self.dot_timer.start()
	EventHandler.emit_signal("player_dot_start", self.dot_count, element)

func take_dot_damage():
	self.stats.set_health(stats.health - self.dot_damage)
	self.dot_timer.wait_time = 1
	self.dot_timer.start()
	print("Player take dot damage %s count %s" % [self.dot_damage, self.dot_count])

func create_levelup_effect():
	var effect = levelup_effect_scene.instantiate()
	self.add_child(effect)
	effect.global_position = global_position
	GameManager.info_box.set_info_text("[center]Glückwunsch!\n\nDu hast [color=red]Level %s[/color] erreicht![/center]" % stats.level)

func use_health_potion():
	if stats.player_inventory['Healthpot'] > 0:
		stats.player_inventory['Healthpot'] -= 1
		EventHandler.emit_signal("player_get_healthpot", stats.player_inventory['Healthpot'])
		stats.heal_player(4)
		var heal_effect = heal_effect_scene.instantiate()
		self.add_child(heal_effect)
		heal_effect.global_position = global_position
		var sound = potion_sound_scene.instantiate()
		self.add_child(sound)
		switch_shader()
	else:
		return

func switch_shader():
	bodySprite.material = heal_shader
	print("[!] Player: Switch healshader")
	await(get_tree().create_timer(0.6).timeout)
	bodySprite.material = dmg_shader
	print("[!] Player: Switch dmgshader")

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
	GameManager.current_world.game_map.add_child(ghost)

func hit_timer_timeout():
	if hit_box_shape.disabled:
		spell_collider.call_deferred("set_disabled", false)
		hit_box_shape.call_deferred("set_disabled", false)
	attackable = true

func hurt_animation_finished():
	Engine.time_scale = 1
	if stats.health <= 0:
		is_alive = false
		EventHandler.emit_signal("player_died")
		GameManager.camera.player = null
		GameManager.player = null
		self.queue_free()
	else:
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

func _play_move_sound():
	sound_controller._play_food_sound()

func _play_run_sound():
	sound_controller._play_run_sound()


func _on_dash_timer_timeout():
	can_dash = true

func _on_dot_timer_timeout():
	if self.dot_count >= 0:
		if not self.is_slowed:
			self.take_dot_damage()
		self.dot_count -= 1
	else:
		self.is_dotted = false
		if self.is_slowed:
			self.is_slowed = false
