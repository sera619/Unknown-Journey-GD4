extends CharacterBody2D

signal enemy_take_damage(dmg)


@export_category("Base Settings")
@export var item_name: String
@export_category("Effect Scenes")
@export var hit_scene: PackedScene
@export var death_scene: PackedScene

@export_category("Sound Scenes")
@export var hit_sound_scene: PackedScene
@export var death_sound_scene: PackedScene

@export_category("Shader Materials")
@export var heal_material: ShaderMaterial
@export var dmg_material: ShaderMaterial

@onready var enemy_stats = $EnemyStats
@onready var enemy_hud = $EnemyHUD
@onready var body_sprite = $Body
@onready var value_display = $ValueDisplay
@onready var enemy_weapon = $WeaponHolder/EnemyWeapon
@onready var player_detector = $PlayerDetector
@onready var soft_collision = $SoftCollision
@onready var sound_controller = $SoundController
@onready var hitbox = $Hitbox
@onready var reward_controller = $RewardController
@onready var wander_controller = $WanderController
@onready var animation_player = $AnimationPlayer
@onready var animation_tree = $AnimationTree
@onready var weapon_collider = $WeaponHolder/EnemyWeapon/CollisionShape2D2
@onready var animation_state =  animation_tree.get("parameters/playback")
@onready var attack_timer: Timer = $WeaponHolder/EnemyWeapon/AttackTimer

enum {
	IDLE,
	WANDER,
	CHASE,
	ATTACK,
	DEATH
}
var state = IDLE
var can_attack: bool = true
var can_move: bool = true 
var knockback: Vector2 = Vector2.ZERO
var last_target_position: Vector2 = Vector2.ZERO


func _ready():
	_on_ready()

func _on_ready():
	animation_tree.active = true
	enemy_weapon.damage = enemy_stats.damage
	hitbox.connect("area_entered", _on_hitbox_entered)
	attack_timer.connect("timeout", _on_attacktimer_timeout)
	enemy_stats.connect("enemy_died", _create_death_effect)
	pick_random_state([IDLE, WANDER])


func _physics_process(delta):
	if knockback != Vector2.ZERO:
		knockback = knockback.move_toward(Vector2.ZERO, enemy_stats.FRICTION * delta)
		set_velocity(knockback)
		move_and_slide()
	if player_detector.can_see_player():
		enemy_hud.visible = true
	else:
		enemy_hud.visible = false
	if velocity != Vector2.ZERO: 
		animation_tree.set("parameters/Move/blend_position", velocity)
		animation_tree.set("parameters/Attack/blend_position", velocity)
		#animation_tree.set("parameters/Hurt/blend_position", velocity)
		animation_tree.set("parameters/Idle/blend_position", velocity)
		animation_state.travel("Move")
	else:
		animation_state.travel("Idle")
	
	match state:
		IDLE:
			_idle_state()
		CHASE:
			_chase_state(delta)
		ATTACK:
			_attack_state()
		WANDER:
			_wander_state(delta)
	
	move_and_slide()

func _create_hit_effect():
	var effect = hit_scene.instantiate()
	self.add_child(effect)
	effect.global_position.y = self.global_position.y + body_sprite.offset.y
	var sound = hit_sound_scene.instantiate()
	self.add_child(sound)
	_switch_dmgshader()

func _create_death_effect():
	body_sprite.visible = false
	hitbox.get_node("CollisionShape2D").set_deferred("disabled", true)
	velocity = Vector2.ZERO
	can_move = false
	can_attack = false
	var sound = death_sound_scene.instantiate()
	self.add_child(sound)
	_switch_dmgshader()
	var effect = death_scene.instantiate()
	effect.connect("effect_finished", kill_enemy)
	GameManager.current_world.game_map.add_child(effect)
	effect.global_position = self.global_position
	effect.global_position.y = self.global_position.y + body_sprite.offset.y

### STATES ###
func _attack_state():
	velocity = Vector2.ZERO
	can_move = false
	can_attack = false
	attack_timer.start()
	var player = null
	if player_detector.can_see_player():
		player = player_detector.player
	else:
		player = null
		state = IDLE
	if player != null:
		animation_tree.set("parameters/Attack/blend_position", global_position.direction_to(player.global_position))
	animation_state.travel("Attack")

func _wander_state(delta):
	if wander_controller.get_time_left() == 0:
		update_wander()
	accelerate_towards_point(wander_controller.target_position, delta)
	if global_position.distance_to(wander_controller.target_position) <= enemy_stats.WANDER_TARGET_RANGE:
		update_wander()

func _idle_state():
	velocity = Vector2.ZERO
	var player: Player = null
	if wander_controller.get_time_left() == 0:
		update_wander()
	if player_detector.can_see_player():
		player = player_detector.player
	else:
		player = null
	
	if player != null:
		var distance = global_position.distance_to(player.global_position)
		if distance > 31 and can_move:
			state = CHASE
		if distance < 33 and can_attack:
			last_target_position = player.global_position
			state = ATTACK

func _chase_state(delta):
	var player: Player = null
	if player_detector.can_see_player():
		player = player_detector.player
	else:
		player = null
	
	if player == null or not can_move:
		state = IDLE
	if player != null:
		var distance = global_position.distance_to(player.global_position)
		if distance >= 32:
			accelerate_towards_point(player.global_position, delta)
		elif distance <= 32:
			state = IDLE
	else:
		state = IDLE


### HELPER ###
func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wander_controller.start_wander_timer(randi_range(1, 3))

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func accelerate_towards_point(point, delta):
	var speed: int = 0
	if state == CHASE or state == IDLE or state == ATTACK:
		speed = enemy_stats.MAX_SPEED
	else:
		speed = enemy_stats.WANDER_SPEED
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * speed, enemy_stats.ACCELERATION * delta)

func kill_enemy():
	check_quest()
	reward_player()
	EventHandler.emit_signal("statistic_update_killed", 1)
	self.call_deferred("queue_free")
	print("[!] Enemy: %s died!" % self.name)

func reward_player():
	if not GameManager.player or enemy_stats.reward_exp == 0:
		return
	GameManager.player.stats.set_exp(GameManager.player.stats.experience + enemy_stats.reward_exp)
	reward_controller.get_reward()

func check_quest():
	if QuestManager.current_quest:
		var quest = QuestManager.current_quest
		if quest.object_name == self.item_name:
			quest.add_item()

func _switch_healshader():
	body_sprite.material = heal_material
	await get_tree().create_timer(0.6).timeout
	body_sprite.material = null

func _switch_dmgshader():
	body_sprite.material = dmg_material
	await get_tree().create_timer(0.6).timeout
	body_sprite.material = null


### SIGNALS ###
func _on_attacktimer_timeout():
	can_attack = true

func _attack_animation_finished():
	can_move = true
	state = IDLE

func _heal_animation_finished():
	if attack_timer.is_stopped():
		can_attack = true
	can_move = true
	state = IDLE

func _hurt_animation_finished():
	can_move = true
	state = IDLE

func _on_hitbox_entered(area):
	if not area.is_in_group("playerSword"):
		return
	if GameManager.player.stats.has_sword and area.attack_type == 0:
		GameManager.player.stats.set_energie(GameManager.player.stats.energie + 1)
	value_display._show_dmg_value(area.damage)
	_create_hit_effect()
	enemy_stats.take_damage(area.damage)
	knockback = area.knockback_vector * 105
	EventHandler.emit_signal("statistic_update_dmg_done", area.damage)
