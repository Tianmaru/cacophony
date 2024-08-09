extends Node

enum Difficulty {EASY, NORMAL, HARD}

var rng_seed : int
var difficulty

# Called when the node enters the scene tree for the first time.
func _ready():
	new_seed()

func new_seed():
	randomize()
	rng_seed = randi()
	seed(rng_seed)

func reset_rng():
	seed(rng_seed)
