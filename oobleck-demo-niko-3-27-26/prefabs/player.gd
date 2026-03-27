


extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var shots = 0
@export var REF_FIREBALL : PackedScene
@onready var animated_sprite = $Sprite2D


var is_attacking: bool = false


	
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
	if animated_sprite.animation == "attack" or animated_sprite.animation == "jump" and is_attacking:
		shoot_fireball()
		is_attacking = false
	

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
			
	# Handle jump.
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")

	
	#adam is a fat fucking chud
	if Input.is_action_pressed("attack"):
		if not is_attacking:
			animated_sprite.play("attack")
			is_attacking = true
		
			
			
	
	if direction > 0: 
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	if !is_attacking:	
		if is_on_floor() and not is_attacking:
			if direction == 0: 
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
		elif not is_on_floor():
			animated_sprite.play("jump")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
