extends AudioStreamPlayer3D

export(float) var delay : float = 0.0

onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	if delay == 0:
		play()
	else:
		timer.wait_time = delay
		timer.start()

func _on_Timer_timeout():
	play()

func _on_SoundPlayer3D_finished():
	queue_free()
