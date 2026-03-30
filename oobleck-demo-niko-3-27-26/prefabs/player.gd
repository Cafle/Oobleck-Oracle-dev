extends CharacterBody2D

const MAX_SPEED_X = 400
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const WALL_VELOCITY = 800
const WALL_JUMP_TIME = 0.1

var dead = false
var facing = 1
var vol_x = 0.0
var vol_y = 0.0
var wall_jump_timer := 0.0
var is_attacking: bool = false

@export var REF_FIREBALL: PackedScene
@export var REF_ICEBALL: PackedScene
@export var REF_LIGHTNING: PackedScene
@export var REF_EXPLOSION: PackedScene

@onready var animated_sprite = $Sprite2D

func _ready() -> void:
	PowerManager.set_power(PowerManager.Power.NONE)
	get_node("../AudioStreamPlayer").play(LevelManager.music_time+0.01)

func shoot_projectile() -> void:
	match PowerManager.current_power:
		PowerManager.Power.NONE:
			_spawn_explosion()
		PowerManager.Power.FIRE:
			_spawn_projectile(REF_FIREBALL)
		PowerManager.Power.ICE:
			_spawn_projectile(REF_ICEBALL)
		PowerManager.Power.LIGHTNING:
			_spawn_projectile(REF_LIGHTNING)

func _spawn_projectile(scene: PackedScene) -> void:
	if scene == null:
		push_warning("No scene assigned for current power.")
		return
	var direction := 1 if not animated_sprite.flip_h else -1
	var projectile = scene.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = Vector2(global_position.x + 15 * direction, global_position.y)
	projectile.rotation = global_position.direction_to(get_global_mouse_position()).angle()

func _spawn_explosion() -> void:
	if REF_EXPLOSION == null:
		push_warning("No explosion scene assigned.")
		return
	var explosion = REF_EXPLOSION.instantiate() 
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position

func _on_sprite_2d_animation_finished() -> void:
	if (animated_sprite.animation == "attack" or animated_sprite.animation == "jump") and is_attacking and not dead :
		shoot_projectile()
		is_attacking = false

func _physics_process(delta: float) -> void:
	wall_jump_timer -= delta
	var direction := Input.get_axis("left", "right")
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	if !is_attacking:
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump")
	
	if not dead:
		if not is_on_floor():
			velocity += get_gravity() * delta
	
	vol_x = velocity.x
	vol_y = velocity.y
	
	if not animated_sprite.flip_h:
		facing = 1
	else:
		facing = -1
	if Input.is_action_just_pressed("up"):
		if is_on_floor():
			vol_y = JUMP_VELOCITY
		elif is_on_wall():
			vol_y = JUMP_VELOCITY
			vol_x = WALL_VELOCITY * -facing
			wall_jump_timer = WALL_JUMP_TIME
	if Input.is_action_just_pressed("attack"):
		if not is_attacking and not dead:
			animated_sprite.play("attack")
			is_attacking = true
			
	if not dead:		
		if wall_jump_timer > 0:
			velocity.x = vol_x
		else:
			if direction != 0:
				velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
		if not dead:
			velocity.y = vol_y
			velocity.x = clamp(velocity.x, -MAX_SPEED_X, MAX_SPEED_X)
			velocity.y = clamp(velocity.y, -400, 400)
	move_and_slide()
