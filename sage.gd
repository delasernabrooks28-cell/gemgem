extends StaticBody2D

@onready var prompt_label: Label = $PromptLabel
@onready var area: Area2D = $Actionable   # use the correct name!

# Set the text scale
var label_scale: Vector2 = Vector2(0.5, 0.5)  # 50% size

func _ready() -> void:
	prompt_label.visible = false
	prompt_label.scale = label_scale  # apply the smaller size
	print(area)  # should print [Area2D:Actionables]

	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		prompt_label.visible = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		prompt_label.visible = false
