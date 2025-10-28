extends AnimatedSprite2D

var fade_time := 0.25        # Total lifetime
var fade_timer := 0.25       # Starts full, counts down

func _ready():
	fade_timer = fade_time

func _process(delta):
	fade_timer -= delta
	var t := fade_timer / fade_time            # 1 -> 0 over lifetime
	
	# 🔥 Pure black silhouette with fade-out
	modulate = Color(0
	, 0, 0, t)

	if fade_timer <= 0:
		queue_free()
