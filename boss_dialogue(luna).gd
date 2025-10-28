extends BaseDialogueTestScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var balloon = load("res://addons/dialogue_manager/example_balloon/small_example_balloon.tscn").instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(resource, title)
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
