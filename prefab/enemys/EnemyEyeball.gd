extends CharacterBody2D



signal enemy_take_damage(damage)
signal enemy_died()
signal enemy_healed(heal)

@export var spell_scene: PackedScene
@export_category("Effect Scenes")
@export var hit_effect_scene: PackedScene
@export var death_effect_scene: PackedScene

@export_category("Sound Scenes")
@export var hurt_sound_scene: PackedScene
@export var death_sound_scene: PackedScene

@export_category("Reward Scenes")
@export var reward_scenes: Array[PackedScene]
@export var reward_gold: int
@export_enum("5%", "10%", "15%", "20%") var reward_chance: int


@onready var enemy_stats = $EnemyStats
@onready var player_detector = $PlayerDetector
@onready var hitbox = $Hitbox
@onready var spellposition = $WeaponAngle/Spellposition
@onready var animation_player = $AnimationPlayer
@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var nav_agent = $NavAgent
@onready var soft_collision = $SoftCollision
@onready var enemy_hud = $EnemyHUD
@onready var stats = $EnemyStats
@onready var attack_timer = $WeaponAngle/AttackTimer
@onready var body = $Body
@onready var wander_controller = $WanderController


enum {
	WANDER,
	IDLE,
	CHASE,
	ATTACK,
	RETURN
}
var state = IDLE
var can_move: bool = true
var can_attack: bool = true
var knockback: Vector2 = Vector2.ZERO
var last_target_position: Vector2 = Vector2.ZERO

func _ready():
	_setup_enemy()

func _setup_enemy():
	animation_tree.active = true
	hitbox.connect("area_entered", take_damage)
	attack_timer.connect("timeout", _on_attacktimer_timeout)
	pick_random_state([IDLE, WANDER])

func _physics_process(delta):
	if knockback != Vector2.ZERO:
		knockback = knockback.move_toward(Vector2.ZERO, stats.FRICTION * delta)
		set_velocity(knockback)
		move_and_slide()
	if player_detector.can_see_player():
		enemy_hud.visible = true
	else:
		enemy_hud.visible = false
	if velocity != Vector2.ZERO: 
		animation_tree.set("parameters/Move/blend_position", velocity)
		animation_tree.set("parameters/Attack/blend_position", velocity)
		animation_tree.set("parameters/Hurt/blend_position", velocity)
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

func _attack_state():
	velocity = Vector2.ZERO
	can_move = false
	can_attack = false
	attack_timer.start()
	animation_state.travel("Attack")

func _wander_state(delta):
	if wander_controller.get_time_left() == 0:
		update_wander()
	accelerate_towards_point(wander_controller.target_position, delta)
	if global_position.distance_to(wander_controller.target_position) <= stats.WANDER_TARGET_RANGE:
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
		if distance > 90 and can_move:
			state = CHASE
		if distance < 90 and can_attack:
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
		if distance >= 90:
			accelerate_towards_point(player.global_position, delta)
		elif distance <= 64:
			state = IDLE
	else:
		state = IDLE

func accelerate_towards_point(point, delta):
	var speed: int = 0
	if state == CHASE or state == IDLE:
		speed = stats.MAX_SPEED
	else:
		speed = stats.WANDER_SPEED
	var direction = global_position.direction_to(point)
	
	velocity = velocity.move_toward(direction * speed, stats.ACCELERATION * delta)


func take_damage(area):
	if area.attack_type == PlayerSword.Type.NORMAL and GameManager.player.stats.level > 4:
		GameManager.player.stats.set_energie(GameManager.player.stats.energie + 1)
	if stats.health >= 0:
		var hit_sound = hurt_sound_scene.instantiate()
		self.add_child(hit_sound)
		var effect = hit_effect_scene.instantiate() 
		var cs = get_tree().current_scene
		effect.global_position= body.global_position
		effect.global_position.y += body.offset.y
		cs.add_child(effect)
		stats.set_health( stats.health - area.damage)
		knockback = area.knockback_vector * 105
		EventHandler.emit_signal("statistic_update_dmg_done", area.damage)
		emit_signal("enemy_take_damage", area.damage)
		if stats.health <= 0:
			var death_sound = death_sound_scene.instantiate()
			self.add_child(death_sound)
			var effect2 = death_effect_scene.instantiate()
			effect2.connect("effect_finished", kill_enemy)
			GameManager.current_world.enemy_container.add_child(effect2)
			effect2.global_position = body.global_position
			self.visible = false
			emit_signal("enemy_died", self)
	else:
		return


func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wander_controller.start_wander_timer(randi_range(1, 3))

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func kill_enemy():
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


# SIGNALS
func _on_attacktimer_timeout():
	can_attack = true

func _on_attack_animation_finished():
	can_move = true
	state = IDLE

func _on_hurt_animation_finished():
	can_move = true
	state = IDLE

# ANIMATION TRIGGER
func _cast_spell():
	var shoot_direction = spellposition.global_position.direction_to(last_target_position)
	var projectile: EnemyProjectile = spell_scene.instantiate()
	projectile.spell_damage = stats.damage
	projectile.global_position = spellposition.global_position
	projectile.direction = shoot_direction
	get_tree().current_scene.add_child(projectile)
