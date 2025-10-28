extends Area2D

@export var speed: float = 300.0
@export var windup_time: float = 0.4

var direction: Vector2 = Vector2.RIGHT
var parent_player: Node = null
var is_launched: bool = false
var has_hit: bool = false

@export var cooldown_time: float = 1.0  # seconds between casts

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func start_windup(player: Node, dir: Vector2) -> void:
	# Check player's cooldown
	if player.get("spell_on_cooldown"):
		return  # player still on cooldown

	parent_player = player
	direction = dir.normalized()
	is_launched = false

	# Set player's cooldown
	player.set("spell_on_cooldown", true)
	_start_player_cooldown(player)

	anim.flip_h = direction.x < 0
	anim.play("firewindup")
	set_process(true)

	await get_tree().create_timer(windup_time).timeout
	launch()

func _process(delta: float) -> void:
	if has_hit:
		return
	if not is_launched and parent_player:
		var offset = Vector2(20, -8)
		if direction.x < 0:
			offset.x *= -1
		global_position = parent_player.global_position + offset
	elif is_launched:
		position += direction * speed * delta

func launch() -> void:
	is_launched = true
	parent_player = null
	anim.flip_h = direction.x < 0
	anim.play("fire")

	self.body_entered.connect(_on_hit)
	self.area_entered.connect(_on_hit)

func _on_hit(body_or_area) -> void:
	if has_hit:
		return
	has_hit = true
	set_process(false)
	anim.flip_h = direction.x < 0
	anim.play("firehit")

	var frames = anim.sprite_frames.get_frame_count("firehit")
	var fps = anim.sprite_frames.get_animation_speed("firehit")
	var duration = frames / fps

	await get_tree().create_timer(duration).timeout
	queue_free()

func _start_player_cooldown(player: Node) -> void:
	# Wait for cooldown_time, then reset player's flag
	await get_tree().create_timer(cooldown_time).timeout
	player.set("spell_on_cooldown", false)
