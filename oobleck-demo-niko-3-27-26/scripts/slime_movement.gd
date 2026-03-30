class_name Slime
extends CharacterBody2D

enum SlimeType { GENERIC, ICE, LIGHTNING, FIRE }
@export var slime_type: SlimeType = SlimeType.FIRE
@export var speed: float = 80.0

var direction: float = 1.0
var floating = false

@onready var wall_ray_left: RayCast2D = $LeftWall
@onready var wall_ray_right: RayCast2D = $RightWall
@onready var ledge_ray_left: RayCast2D = $LeftLedge
@onready var ledge_ray_right: RayCast2D = $RightLedge
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	global_position.x += direction * speed * delta
	_check_turn(delta)
	_update_sprite()
	move_and_slide()

	
func _check_turn(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		velocity.y = 0
		if direction > 0:
			if wall_ray_right.is_colliding() or not ledge_ray_right.is_colliding():
				direction = -1.0
		else:
			if wall_ray_left.is_colliding() or not ledge_ray_left.is_colliding():
				direction = 1.0


func _update_sprite() -> void:
	animated_sprite.flip_h = direction > 0

func die() -> void:
	match slime_type:
		SlimeType.GENERIC:
			PowerManager.reset_power()
		SlimeType.FIRE:
			PowerManager.set_power(PowerManager.Power.FIRE)
		SlimeType.ICE:
			PowerManager.set_power(PowerManager.Power.ICE)
		SlimeType.LIGHTNING:
			PowerManager.set_power(PowerManager.Power.LIGHTNING)
	queue_free()

func catch_fire() -> void:
	die()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("fireball"):
		die()
			

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "PLAYER":
		var PLAYER = get_node("../PLAYER")
		PLAYER.dead = true
		PLAYER.velocity = Vector2(0,0)
		
		create_tween().tween_property(PLAYER, "modulate", Color.BLACK, 0.4)
		
		await get_tree().create_timer(0.4).timeout
		LevelManager.music_time = get_node("../AudioStreamPlayer").get_playback_position()
		get_tree().reload_current_scene()
