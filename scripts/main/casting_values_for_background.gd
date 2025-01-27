extends Node2D

@onready var player: CharacterBody2D = $player
@onready var background: ParallaxBackground = $background

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if background.colorRect.material:  
		background.colorRect.material.set_shader_parameter("playerY", player.global_position.y)
