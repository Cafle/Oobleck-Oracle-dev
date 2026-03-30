class_name BurnableMap
extends TileMapLayer

@export var burn_time: float = 2.0
@export var burn_scene: PackedScene  # Drag burn_sprite scene in Inspector
var _burning := {}
var _burn_sprites: Dictionary = {}  # coords -> AnimatedSprite2D

func try_burn_tile(coords: Vector2i) -> void:
	for offset in [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		var check: Vector2i = coords + offset
		if _is_burnable(check):
			_start_burn_cluster(check)
			return

func _start_burn_cluster(start_coords: Vector2i) -> void:
	var stack: Array[Vector2i] = [start_coords]
	var visited := {}
	var delay := 0.0
	while not stack.is_empty():
		var current: Vector2i = stack.pop_back()
		if visited.has(current):
			continue
		visited[current] = true
		if _burning.has(current):
			for neighbor in get_surrounding_cells(current):
				if not visited.has(neighbor):
					stack.append(neighbor)
			continue
		if not _is_burnable(current):
			continue
		_start_burn_delayed(current, delay)
		delay += 0.1
		for neighbor in get_surrounding_cells(current):
			if not visited.has(neighbor):
				stack.append(neighbor)

func _is_burnable(coords: Vector2i) -> bool:
	if _burning.has(coords):
		return false
	var data := get_cell_tile_data(coords)
	return data != null and data.get_custom_data("burnable") == true

func _start_burn_delayed(coords: Vector2i, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	_start_burn(coords)

func _start_burn(coords: Vector2i) -> void:
	if _burning.has(coords):
		return
	_burning[coords] = true
	_spawn_burn_sprite(coords)
	_burn_tile_async(coords)  # Intentional fire-and-forget coroutine

func _spawn_burn_sprite(coords: Vector2i) -> void:
	if burn_scene == null:
		push_warning("BurnableMap: No burn scene assigned.")
		return
	var sprite := burn_scene.instantiate()
	sprite.global_position = map_to_local(coords)
	add_child(sprite)
	_burn_sprites[coords] = sprite

func _burn_tile_async(coords: Vector2i) -> void:
	print(str(coords) + " is burning!")
	await get_tree().create_timer(burn_time).timeout
	var data := get_cell_tile_data(coords)
	if data != null and data.get_custom_data("burnable") == true:
		erase_cell(coords)
		print(str(coords) + " burned down!")
	if _burn_sprites.has(coords):
		_burn_sprites[coords].queue_free()
		_burn_sprites.erase(coords)
	_burning.erase(coords)
