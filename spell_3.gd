extends Area2D

@export var duration: float = 0.35
@export var offset: Vector2 = Vector2(0, -8)  # centered but slightly upward
@export var knockback_force: float = 280.0

var direction: Vector2 = Vector2.RIGHT
var parent_player: Node = null
var has_slash: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func start_windup(player: Node, dir: Vector2) -> void:  # ✅ renamed
	parent_player = player
	direction = dir.normalized()
	has_slash = true

	anim.flip_h = direction.x < 0
	anim.play("darkslash")

	self.body_entered.connect(_on_hit)
	self.area_entered.connect(_on_hit)

	# auto-remove after slash duration
	await get_tree().create_timer(duration).timeout
	queue_free()

func _process(delta: float) -> void:
	if parent_player:
		var final_offset = offset
		if direction.x < 0:
			final_offset.x *= -1
		global_position = parent_player.global_position + final_offset

func _on_hit(body_or_area) -> void:
	if not has_slash:
		return
	if body_or_area.has_method("apply_central_impulse"):
		body_or_area.apply_central_impulse(direction * knockback_force)
