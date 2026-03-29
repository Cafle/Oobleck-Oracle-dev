#stupid fat ungly whore licking chud.

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

@export var REF_FIREBALL : PackedScene
@onready var animated_sprite = $Sprite2D


func shoot_fireball():
	var direction = 0
	if REF_FIREBALL:
		if not animated_sprite.flip_h:
			direction = 1
			print("face right")
		else:
			print("face left")
			direction = -1
		var fireball = REF_FIREBALL.instantiate()
		
		get_tree().current_scene.add_child(fireball)
		if direction > 0: 
			fireball.global_position = Vector2(self.global_position.x + 15,self.global_position.y)
		elif direction < 0:
			fireball.global_position = Vector2(self.global_position.x - 15,self.global_position.y)
			
		var fireball_rotation = self.global_position.direction_to(get_global_mouse_position()).angle()
		fireball.rotation = fireball_rotation


func _on_sprite_2d_animation_finished() -> void:
	if (animated_sprite.animation == "attack" or animated_sprite.animation == "jump") and is_attacking:
		shoot_fireball()
		is_attacking = false


func _physics_process(delta: float) -> void:
	
	# Timer for wall jump momentum
	wall_jump_timer -= delta
	
	var direction := Input.get_axis("left", "right")
	
	# Flip sprite
	if direction > 0: 
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	# Animations
	if !is_attacking:
		if is_on_floor():
			if direction == 0: 
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		else:
			animated_sprite.play("jump")
	
	if not dead:
		# Gravity
		if not is_on_floor():
			velocity += get_gravity() * delta
	
	vol_x = velocity.x
	vol_y = velocity.y
	
	# Facing direction
	if not animated_sprite.flip_h:
		facing = 1
	else:
		facing = -1
	
	# Jump
	if Input.is_action_just_pressed("up"):
		if is_on_floor():
			vol_y = JUMP_VELOCITY
			
		elif is_on_wall():
			# WALL JUMP FIX
			vol_y = JUMP_VELOCITY
			vol_x = WALL_VELOCITY * -facing
			wall_jump_timer = WALL_JUMP_TIME
	
	# Attack
	if Input.is_action_just_pressed("attack"):
		if not is_attacking and not dead:
			animated_sprite.play("attack")
			is_attacking = true

	if not dead:	
		# Horizontal movement
		if wall_jump_timer > 0:
			# Keep momentum during wall jump
			velocity.x = vol_x
		else:
			if direction != 0:
				velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
	
	
		# Apply vertical velocity
		velocity.y = vol_y
		
		# Clamp speed
		velocity.x = clamp(velocity.x, -MAX_SPEED_X, MAX_SPEED_X)
		velocity.y = clamp(velocity.y, -400, 400)

	move_and_slide()
