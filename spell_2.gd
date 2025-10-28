extends Area2D

@export var explosion_radius: float = 64.0
@export var knockback_force: float = 600.0
@export var damage: int = 20
@export var windup_time: float = 0.2

var parent_player: Node = null
var has_exploded: bool = false
var direction: Vector2 = Vector2.RIGHT

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func start_windup(player: Node, dir: Vector2) -> void:
	parent_player = player
	direction = dir.normalized()
	has_exploded = false

	anim.flip_h = direction.x < 0
	anim.play("firewindup")

	set_process(true)
	await get_tree().create_timer(windup_time).timeout
	explode()

func _process(delta: float) -> void:
	# Follow the player until it explodes
	if not has_exploded and parent_player:
		var offset = Vector2(28, -6)   # moved slightly more forward & up
		if direction.x < 0:
			offset.x *= -1             # flip if facing left
		global_position = parent_player.global_position + offset


func explode() -> void:
	if has_exploded:
		return
	has_exploded = true
	set_process(false)

	anim.play("fireslash")

	# Expand hitbox temporarily
	if collision and collision.shape and collision.shape is RectangleShape2D:
		(collision.shape as RectangleShape2D).size = Vector2(explosion_radius, explosion_radius)

	# Knockback + damage
	for body in get_overlapping_bodies():
		if body.has_method("apply_knockback"):
			var dir = (body.global_position - global_position).normalized()
			body.apply_knockback(dir * knockback_force)
		if body.has_method("apply_damage"):
			body.apply_damage(damage)

	# wait for animation before cleanup
	var frames: int = anim.sprite_frames.get_frame_count("fireslash")
	var fps: float = anim.sprite_frames.get_animation_speed("fireslash")
	var duration: float = frames / max(1.0, fps)

	await get_tree().create_timer(duration).timeout
	queue_free()
