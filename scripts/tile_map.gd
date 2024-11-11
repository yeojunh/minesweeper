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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# helper functions
func is_mine(pos): 
	return get_cell_source_id(mine_layer, pos) != -1
