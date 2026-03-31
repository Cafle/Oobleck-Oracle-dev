class_name TileMapEffects
extends TileMapLayer

# Burn settings
@export var burn_time: float = 2.0
@export var burn_scene: PackedScene

# Freeze settings
@export var frozen_source_id: int = 0
const FREEZE_MAP: Dictionary = {
	Vector2i(0, 12): Vector2i(0, 8),
	Vector2i(0, 13): Vector2i(0, 9),
	Vector2i(0, 14): Vector2i(0, 10),
	Vector2i(0, 15): Vector2i(0, 11), 
}

var _burning := {}
var _frozen := {}
var _burn_sprites: Dictionary = {}

#FIRE
#METHOD DESCRIPTION: CHECKS IF TILE AND AND SURRONDING TILES ARE PART OF BURNABLE GROUP
#IF BURNABLE, PROCEEDS TO BURN CLUSTER FUNCTION
func try_burn_tile(coords: Vector2i) -> void:
	for offset in [Vector2i(0,0), Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
		var check: Vector2i = coords + offset
		if _is_burnable(check):
			_start_burn_cluster(check)
			return
#METHOD DESCRIPTION: CREATES A STACK AND VISTED DICT TO TRACK BURNING TILES 
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
	_burn_tile_async(coords)

func _spawn_burn_sprite(coords: Vector2i) -> void:
	if burn_scene == null:
		push_warning("TileMapEffects: No burn scene assigned.")
		return
	var sprite := burn_scene.instantiate()
	sprite.global_position = map_to_local(coords)
	add_child(sprite)
	_burn_sprites[coords] = sprite

func _burn_tile_async(coords: Vector2i) -> void:
	await get_tree().create_timer(burn_time).timeout
	var data := get_cell_tile_data(coords)
	if data != null and data.get_custom_data("burnable") == true:
		erase_cell(coords)
	if _burn_sprites.has(coords):
		_burn_sprites[coords].queue_free()
		_burn_sprites.erase(coords)
	_burning.erase(coords)

#ICE

func try_freeze_tile(coords: Vector2i) -> void:
	for offset in [Vector2i(0,0), Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
		var check: Vector2i = coords + offset
		if _is_freezable(check):
			_start_ice_cluster(check)
			return

func _start_ice_cluster(start_coords: Vector2i) -> void:
	var stack: Array[Vector2i] = [start_coords]
	var visited := {}
	var delay := 0.0
	while not stack.is_empty():
		var current: Vector2i = stack.pop_back()
		if visited.has(current):
			continue
		visited[current] = true
		if _frozen.has(current):
			for neighbor in get_surrounding_cells(current):
				if not visited.has(neighbor):
					stack.append(neighbor)
			continue
		if not _is_freezable(current):
			continue
		_start_ice_delayed(current, delay)
		delay += 0.1
		for neighbor in get_surrounding_cells(current):
			if not visited.has(neighbor):
				stack.append(neighbor)

func _is_freezable(coords: Vector2i) -> bool:
	if _frozen.has(coords):
		return false
	var data := get_cell_tile_data(coords)
	return data != null and data.get_custom_data("freezable") == true

func _start_ice_delayed(coords: Vector2i, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	_start_freeze(coords)

func _start_freeze(coords: Vector2i) -> void:
	if _frozen.has(coords):
		return
	_freeze_tile(coords)

func _freeze_tile(coords: Vector2i) -> void:
	if _frozen.has(coords):
		return
	# Store original source ID alongside frozen state
	_frozen[coords] = get_cell_source_id(coords)
	var current_atlas := get_cell_atlas_coords(coords)
	var alt_tile := get_cell_alternative_tile(coords)
	var flip = is_cell_flipped_h(coords)
	if FREEZE_MAP.has(current_atlas):
		if flip:
			set_cell(coords, frozen_source_id, FREEZE_MAP[current_atlas], alt_tile)
		else:
			set_cell(coords, frozen_source_id, FREEZE_MAP[current_atlas])

# REVERSES THE FREEZE_MAP LOOKUP TO FIND THE ORIGINAL ATLAS COORDS
# RETURNS Vector2i(-1,-1) AS A SENTINEL VALUE IF NO MATCH IS FOUND
# (SENTINEL USED BECAUSE Vector2i HAS NO NULL STATE)
func _get_original_atlas(frozen_atlas: Vector2i) -> Vector2i:
	for original in FREEZE_MAP:
		if FREEZE_MAP[original] == frozen_atlas:
			return original
	return Vector2i(-1, -1)

# CHECKS TILE AND SURROUNDING TILES FOR FROZEN STATE
# IF FROZEN, PROCEEDS TO MELT THAT TILE
func try_melt_tile(coords: Vector2i) -> void:
	for offset in [Vector2i(0,0), Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
		var check: Vector2i = coords + offset
		if _frozen.has(check):
			_start_melt_cluster(check)
			return

# RESTORES A FROZEN TILE TO ITS ORIGINAL ATLAS COORDS AND SOURCE ID
# ORIGINAL SOURCE ID WAS STORED IN _frozen DICT WHEN TILE WAS FROZEN
# ERASES TILE FROM _frozen SO IT CAN BE FROZEN AGAIN LATER
func _melt_tile(coords: Vector2i) -> void:
	if not _frozen.has(coords):
		return
	var current_atlas := get_cell_atlas_coords(coords)
	var original := _get_original_atlas(current_atlas)
	var alt_tile := get_cell_alternative_tile(coords)
	var original_source_id: int = _frozen[coords]
	if original != Vector2i(-1, -1):
		set_cell(coords, original_source_id, original, alt_tile)
	_frozen.erase(coords)
	
	
	

func _start_melt_delayed(coords: Vector2i, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	_melt_tile(coords)


func _start_melt_cluster(start_coords: Vector2i) -> void:
	var stack: Array[Vector2i] = [start_coords]
	var visited := {}
	var delay := 0.0
	while not stack.is_empty():
		var current: Vector2i = stack.pop_back()
		if visited.has(current):
			continue
		visited[current] = true
		if not _frozen.has(current):
			continue
		_start_melt_delayed(current, delay)
		delay += 0.1
		for neighbor in get_surrounding_cells(current):
			if not visited.has(neighbor):
				stack.append(neighbor)


#LIGHTNING
# NEED-TO-IMPLEMENT: 
# DATA LAYERS:
# conductive (bool) custom data layer for conductive tiles
# switch (bool) custom data layer for switch tiles
# door_id (int) 
# DOOR_MAP
# provide proper vector pair for switching from closed to open door
const DOOR_MAP: Dictionary = {
	Vector2i(0, 27): Vector2i(1, 27),
	Vector2i(0, 26): Vector2i(1, 26),
	Vector2i(0, 5): Vector2i(1, 27),
	Vector2i(1, 5): Vector2i(1, 27),
	Vector2i(2, 5): Vector2i(1, 27),
	Vector2i(0, 6): Vector2i(1, 27),
	Vector2i(1, 6): Vector2i(1, 27),
	Vector2i(2, 6): Vector2i(1, 27)
}

var _shocked := {}

func try_shock_tile(coords: Vector2i) -> void:
	for offset in [Vector2i(0,0), Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
		var check: Vector2i = coords + offset
		if _is_conductive(check):
			_start_shock_cluster(check)
			return

func _start_shock_cluster(start_coords: Vector2i) -> void:
	var stack: Array[Vector2i] = [start_coords]
	var visited := {}
	var delay := 0.0
	while not stack.is_empty():
		var current: Vector2i = stack.pop_back()
		if visited.has(current):
			continue
		visited[current] = true
		if _shocked.has(current):
			for neighbor in get_surrounding_cells(current):
				if not visited.has(neighbor):
					stack.append(neighbor)
			continue
		if not _is_conductive(current):
			continue
		_start_shock_delayed(current, delay)
		delay += 0.1
		for neighbor in get_surrounding_cells(current):
			if not visited.has(neighbor):
				stack.append(neighbor)

func _is_conductive(coords: Vector2i) -> bool:
	if _shocked.has(coords):
		return false
	var data := get_cell_tile_data(coords)
	return data != null and data.get_custom_data("conductive") == true

func _start_shock_delayed(coords: Vector2i, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	_start_shock(coords)

func _start_shock(coords: Vector2i) -> void:
	if _shocked.has(coords):
		return
	_shock_tile(coords)

func _shock_tile(coords: Vector2i) -> void:
	if _shocked.has(coords):
		return
	_shocked[coords] = true
	var data := get_cell_tile_data(coords)
	if data != null and data.get_custom_data("switch") == true:
		_activate_switch(coords)
# POTENTIAL ISSUE: 
#CHECKS EVERY NEARBY TILE, speed / lag scales poorly with tile amount
#POTENTIAL FIX: pre-determine door coords
func _activate_switch(coords: Vector2i) -> void:
	# grab the door_id from the switch tile that was shocked
	var switch_data := get_cell_tile_data(coords)
	if switch_data == null:
		return
	var switch_id = switch_data.get_custom_data("door_id")
	# scan every tile on the map for a matching door_id
	var used_cells := get_used_cells()
	for cell in used_cells:
		var cell_data := get_cell_tile_data(cell)
		# skip tiles with no data or a non-matching door_id
		if cell_data != null and cell_data.get_custom_data("door_id") == switch_id:
			var cell_atlas := get_cell_atlas_coords(cell)
			# swap the closed door atlas coords to the open door frame
			if DOOR_MAP.has(cell_atlas):
				set_cell(cell, get_cell_source_id(cell), DOOR_MAP[cell_atlas])
