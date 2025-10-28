extends Node2D

@onready var area: Area2D = $Area2D  # the Area2D child of this spike

func _ready():
	area.connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		body.die()
