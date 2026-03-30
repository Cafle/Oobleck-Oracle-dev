class_name Slime
extends Area2D

@export var speed: float = 80.0
var direction: float = 1.0

@onready var wall_ray_left: RayCast2D = $LeftWall
@onready var wall_ray_right: RayCast2D = $RightWall
@onready var ledge_ray_left: RayCast2D = $LeftLedge
@onready var ledge_ray_right: RayCast2D = $RightLedge
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	global_position.x += direction * speed * delta
	_check_turn()
	_update_sprite()

func _check_turn() -> void:
	if direction > 0:
		if wall_ray_right.is_colliding() or not ledge_ray_right.is_colliding():
			direction = -1.0
	else:
		if wall_ray_left.is_colliding() or not ledge_ray_left.is_colliding():
			direction = 1.0

func _update_sprite() -> void:
	animated_sprite.flip_h = direction > 0

func die() -> void:
	queue_free()

func catch_fire() -> void:
	die()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("fireball"):
		die()


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	var PLAYER = get_node("../PLAYER")
	PLAYER.velocity = Vector2(0,0)
	
	create_tween().tween_property(PLAYER, "modulate", Color.BLACK, 0.4)
	
	await get_tree().create_timer(0.4).timeout
	LevelManager.music_time = get_node("../AudioStreamPlayer").get_playback_position()
	print(get_node("../AudioStreamPlayer").get_playback_position())
	get_tree().reload_current_scene()
	pass # Replace with function body.
