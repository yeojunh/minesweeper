extends TileMap

# grid variables 
const ROWS : int = 14
const COLS : int = 15
const CELL_SIZE : int = 50

# tilemap variables 
var tile_id : int = 0

# layer variables 
var mine_layer : int = 0
var number_layer : int = 1
var grass_layer : int = 2
var flag_layer : int = 3
var hover_layer : int = 4

# atlas coordinates 
var mine_atlas := Vector2i(4, 0)
var flag_atlas := Vector2i(5, 0)
var hover_atlas := Vector2i(6, 0)
var number_atlas : Array = generate_number_atlas()
# array to store mine coordinates
var mine_coords := []

func generate_number_atlas(): 
	var a := []
	for i in range(8): 
		a.append(Vector2i(i, 1))
	return a

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()

func new_game(): 
	clear()
	mine_coords.clear()
	generate_mines()
	generate_numbers()
	generate_grass()

func generate_mines(): 
	for i in range(get_parent().TOTAL_MINES): 
		var mine_pos = Vector2i(randi_range(0, COLS - 1), randi_range(0, ROWS - 1))
		while mine_coords.has(mine_pos): 
			# prevent duplicate mines in the same cell 
			mine_pos = Vector2i(randi_range(0, COLS - 1), randi_range(0, ROWS - 1))
		mine_coords.append(mine_pos)
		# add mine to tilemap 
		set_cell(mine_layer, mine_pos, tile_id, mine_atlas)

func generate_numbers(): 
	#print(get_empty_cells())
	for i in get_empty_cells():
		var mine_count : int = 0
		for j in get_all_surrounding_cells(i): 
			if is_mine(j): 
				mine_count += 1
		# add number cell to tile map 
		if mine_count > 0: 
			set_cell(number_layer, i, tile_id, number_atlas[mine_count - 1])

func generate_grass(): 
	for y in range(ROWS): 
		for x in range(COLS): 
			var toggle = (x + y) % 2 # toggle for checkered pattern
			set_cell(grass_layer, Vector2i(x, y), tile_id, Vector2i(3 - toggle, 0))

func get_empty_cells(): 
	var empty_cells := []
	# iterate over grid 
	for y in range(ROWS): 
		for x in range(COLS): 
			# check if cell is empty and add it to array 
			if not is_mine(Vector2i(x, y)): 
				empty_cells.append(Vector2i(x, y))
	return empty_cells

func get_all_surrounding_cells(middle_cell): 
	var surrounding_cells := []
	var target_cell
	for y in range(3): 
		for x in range(3): 
			target_cell = middle_cell + Vector2i(x - 1, y - 1)
			# skip cell if it is the middle cell 
			if target_cell != middle_cell: 
				if (target_cell.x >= 0 and target_cell.x < COLS - 1  and target_cell.y >= 0 and target_cell.y < ROWS - 1): 
					surrounding_cells.append(target_cell)
	return surrounding_cells

func _input(event): 
	if event is InputEventMouseButton: 
		# check if mouse is on game board 
		if event.position.y < ROWS * CELL_SIZE: 
			var map_pos := local_to_map(event.position)
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed: 
				# check that there is no flag 
				if not is_flag(map_pos): 
					# check if there is a mine 
					if is_mine(map_pos): 
						print("Game over")
					else: 
						process_left_click(map_pos)
			# right click places and removes flags 
			elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed: 
				process_right_click(map_pos)

func process_left_click(pos): 
	var revealed_cells := []
	var cells_to_reveal := [pos]
	while not cells_to_reveal.is_empty(): 
		# clear cell and mark it cleared 
		erase_cell(grass_layer, cells_to_reveal[0])
		revealed_cells.append(cells_to_reveal[0])
		# if cell has a flag, then clear it 
		if is_flag(cells_to_reveal[0]): 
			erase_cell(flag_layer, cells_to_reveal[0])
		if not is_number(cells_to_reveal[0]): 
			cells_to_reveal = reveal_surrounding_cells(cells_to_reveal, revealed_cells)
		# remove processed cell from array 
		cells_to_reveal.erase(cells_to_reveal[0])

func process_right_click(pos): 
	# check if it is a grass cell 
	if is_grass(pos): 
		if is_flag(pos): 
			erase_cell(flag_layer, pos)
		else: 
			set_cell(flag_layer, pos, tile_id, flag_atlas)

func reveal_surrounding_cells(cells_to_reveal, revealed_cells): 
	for i in get_all_surrounding_cells(cells_to_reveal[0]):
		# check that cell is not already revealed
		if not revealed_cells.has(i): 
			if not cells_to_reveal.has(i): 
				cells_to_reveal.append(i) 
	return cells_to_reveal
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	highlight_cell()

func highlight_cell(): 
	clear_layer(hover_layer)
	var mouse_pos := local_to_map(get_local_mouse_position())
	# hover over grass cells or number cells
	if is_grass(mouse_pos): 
		set_cell(hover_layer, mouse_pos, tile_id, hover_atlas)
	elif is_number(mouse_pos): 
		set_cell(hover_layer, mouse_pos, tile_id, hover_atlas)

# helper functions
func is_mine(pos): 
	return get_cell_source_id(mine_layer, pos) != -1
	
func is_grass(pos): 
	return get_cell_source_id(grass_layer, pos) != -1
	
func is_number(pos): 
	return get_cell_source_id(number_layer, pos) != -1

func is_flag(pos): 
	return get_cell_source_id(flag_layer, pos) != -1
