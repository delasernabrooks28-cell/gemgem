extends Area2D

@export var duration: float = 0.5       # how long the attack stays
@export var forward_offset: float = 40  # distance in front of player
@export var upward_offset: float = -6   # slightly above player center
@export var beam_length: float = 120.0  # length of the slash
@export var beam_thickness: float = 32.0
@export var knockback_force: float = 350.0

var direction: Vector2 = Vector2.RIGHT
var parent_player: Node = null
var active: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func start_windup(player: Node, dir: Vector2) -> void:
	parent_player = player
	direction = dir.normalized()
	active = true

	# Flip sprite correctly
	anim.flip_h = direction.x < 0
	anim.play("shadowlaunch")

	# Resize hitbox to match the beam
	if collision.shape is RectangleShape2D:
		var rect := collision.shape as RectangleShape2D
		rect.size = Vector2(beam_length, beam_thickness)

	# Move hitbox origin so it extends forward
	collision.position = Vector2(beam_length / 2, 0)
	if direction.x < 0:
		collision.position.x = -beam_length / 2

	# Connect hits
	self.body_entered.connect(_on_hit)
	self.area_entered.connect(_on_hit)

	# Auto-remove after duration
	await get_tree().create_timer(duration).timeout
	queue_free()

func _process(delta: float) -> void:
	if parent_player:
		# Lock to player position + offset
		var x_offset = forward_offset if direction.x > 0 else -forward_offset
		global_position = parent_player.global_position + Vector2(x_offset, upward_offset)

func _on_hit(body_or_area) -> void:
	if not active:
		return
	if body_or_area.has_method("apply_central_impulse"):
		body_or_area.apply_central_impulse(direction * knockback_force)
