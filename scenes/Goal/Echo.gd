extends Spatial


onready var timer = $Timer
onready var sfx = $Ping

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func start(t):
	timer.wait_time = t
	timer.start()

func _on_Timer_timeout():
	sfx.play()

func _on_Ping_finished():
	call_deferred("queue_free")
