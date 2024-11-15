extends Node

# game variable 
const TOTAL_MINES : int = 40
var time_elapsed : float
var remaining_mines : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()

func new_game(): 
	time_elapsed = 0
	remaining_mines = TOTAL_MINES

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_elapsed += delta
	$HUD.get_node("Stopwatch").text = str(int(time_elapsed))
	$HUD.get_node("RemainingMines").text = str(remaining_mines)

func _on_tile_map_flag_placed() -> void:
	remaining_mines -= 1


func _on_tile_map_flag_removed() -> void:
	remaining_mines += 1
