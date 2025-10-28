extends CanvasLayer

@export var max_hearts: int = 3
var current_hearts: int

@onready var hearts_container = $HBoxContainer
const HEART_SCENE = preload("res://player_ui.tscn")

func _ready():
	current_hearts = max_hearts
	_create_hearts()

func _create_hearts():
	for i in range(max_hearts):
		var heart = HEART_SCENE.instantiate()
		hearts_container.add_child(heart)
		heart.play("idle")

func take_damage(amount: int):
	for i in range(amount):
		if current_hearts > 0:
			current_hearts -= 1
			var heart = hearts_container.get_child(current_hearts) as AnimatedSprite2D
			heart.play("drain")
