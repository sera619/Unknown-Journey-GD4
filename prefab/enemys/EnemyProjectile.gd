class_name EnemyProjectile
extends EnemyWeapon


@export var spell_damage: int = 1
@export var launch_speed: float = 30.0
@export var speed: float = 70.0
@export var lifetime: float = 3.0
@export var is_anitamed: bool
@export_enum("Direct", "Homeing") var projectile_type: String = "Direct"
@export_enum( "None", "Fire", "Ice", "Poison", "Lightning") var spell_element: String = "None"
@export var spell_sound_scene: PackedScene
@export var impact_effect_scene: PackedScene
@export var impact_sound_scene: PackedScene
@onready var timer = $Timer
@onready var targetDetector = $TargetDetector
@onready var animPlayer = $AnimationPlayer
var drag_factor := 0.15 : set = set_drag_factor

var current_velocity: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO
var target = null
var is_active = false

	
func _ready():
	is_active = true
	self.damage = spell_damage
	self.set_element_type(spell_element)
	look_at(global_position + direction)
	knockback_vector = direction
	self.connect("area_entered",Callable(self,"_destroy_projectile"))
	timer.connect("timeout",Callable(self,"_on_timer_timeout"))
	if projectile_type == "Homeing":
		targetDetector.connect("body_entered",Callable(self,"_on_target_detector_body_entered"))
	if is_anitamed:
		animPlayer.play("loop")
	current_velocity = speed * Vector2.RIGHT.rotated(rotation)
	timer.start(lifetime)
	_play_spell_sound()

func _play_spell_sound():
	if spell_sound_scene:
		var sound = spell_sound_scene.instantiate()
		self.add_child(sound) 

func set_projectile_damage(dmg):
	damage = dmg

func _physics_process(delta):
	if is_active:
		if direction.x >= 0:
			$Sprite2D.flip_v = false
			$CollisionShape2D.position.x = 8
		else:
			$CollisionShape2D.position.x =  -8
			$Sprite2D.flip_v = true
		match projectile_type: 
			"Homeing":
				if target != null:
					direction = global_position.direction_to(target.global_position)
				if direction != Vector2.ZERO:
					var desired_velocity = direction * speed
					#var previous_velocity = current_velocity
					var change = (desired_velocity - current_velocity) * drag_factor
					current_velocity += change
					position += current_velocity * delta
					look_at(global_position + current_velocity)
			"Direct":
				position += direction * speed * delta
				look_at(global_position + direction)



func set_drag_factor(new_value: float) -> void:
	drag_factor = clamp(new_value, 0.01, 0.5)

func _on_timer_timeout():
	queue_free()

func _on_target_detector_body_entered(body):
	if body.name != "Player":
		return
	else:
		target = body.hitbx

func _create_impact_effect():
	$Sprite2D.visible = false
	$CollisionShape2D.call_deferred("set_disabled", true)
	var effect = impact_effect_scene.instantiate()
	effect.connect("effect_finished", self._kill)
	effect.global_position = self.global_position
	var sound = impact_sound_scene.instantiate()
	sound.global_position = self.global_position
	effect.add_child(sound)
	is_active = false
	get_tree().current_scene.add_child(effect)



func _kill():
	self.call_deferred("queue_free")


func _destroy_projectile(area):
	if !area.is_in_group("playerHitbox"):
		return
	else:
		_create_impact_effect()
