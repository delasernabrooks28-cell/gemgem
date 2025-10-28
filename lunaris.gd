extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var actionable: Area2D = $Actionable

var waiting_for_animation := false
var defeated := false

func _ready() -> void:
	# Register this boss globally
	DialogueManager.lunaris = self
	if anim.sprite_frames.has_animation("Idle"):
		anim.play("Idle")
	# Connect player entering Actionable area
	actionable.connect("body_entered", Callable(self, "_on_player_entered"))

# Player enters the boss area
func _on_player_entered(body):
	if defeated:
		return
	if body.is_in_group("player"):
		# Lock player immediately
		body.lock_player()
		face_player()
		DialogueManager.show_example_dialogue_balloon(actionable.dialogue_resource, actionable.dialogue_start)

# Make Lunaris face the player
func face_player():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		anim.flip_h = player.global_position.x < global_position.x

# Trigger correct answer animation
func trigger_correct_answer() -> void:
	face_player()
	if anim.sprite_frames.has_animation("Hurt"):
		anim.play("Hurt")
		var length = get_animation_length("Hurt")
		var t = Timer.new()
		t.wait_time = length
		t.one_shot = true
		t.autostart = true
		add_child(t)
		t.connect("timeout", Callable(self, "_on_correct_finished"))

func _on_correct_finished():
	if anim.sprite_frames.has_animation("Idle"):
		anim.play("Idle")

# Trigger wrong answer animation
func trigger_wrong_answer() -> void:
	if waiting_for_animation:
		return
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.lock_player()
	face_player()
	if anim.sprite_frames.has_animation("Attack"):
		anim.play("Attack")
		waiting_for_animation = true
		var length = get_animation_length("Attack")
		var t = Timer.new()
		t.wait_time = length
		t.one_shot = true
		t.autostart = true
		add_child(t)
		t.connect("timeout", Callable(self, "_on_attack_finished").bind(player))

func _on_attack_finished(player):
	waiting_for_animation = false
	if anim.sprite_frames.has_animation("Idle"):
		anim.play("Idle")
	if player:
		player.die()

# Trigger death animation
func trigger_death():
	defeated = true
	face_player()
	if anim.sprite_frames.has_animation("Death"):
		anim.play("Death")
	# Unlock player and remove boss after animation
	var length = get_animation_length("Death")
	var t = Timer.new()
	t.wait_time = length
	t.one_shot = true
	t.autostart = true
	add_child(t)
	t.connect("timeout", Callable(self, "_on_death_finished"))

func _on_death_finished():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.unlock_player()
	queue_free() # remove boss from scene

# Helper to get animation length
func get_animation_length(anim_name: String) -> float:
	var frames = anim.sprite_frames.get_frame_count(anim_name)
	var fps = anim.sprite_frames.get_animation_speed(anim_name)
	if fps <= 0:
		return 0.5 # fallback
	return frames / fps
