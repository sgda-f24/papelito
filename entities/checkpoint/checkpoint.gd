extends Node2D
class_name Checkpoint

@onready var outline_shader = preload("res://entities/outline.gdshader")
@onready var sprite: Sprite2D = %Book

@export var does_win = false
@export var selected = false
@export var amplitude = 0.25
@export var frequency = 0.001

func _process(delta: float) -> void:
	position.y += sin(Time.get_ticks_msec()*frequency) * amplitude	
	if selected and does_win:
		UI.ToggleUi.emit("main_menu", true, "")
	if selected:
		sprite.material.set_shader_parameter("width", 10)
	else:
		sprite.material.set_shader_parameter("width", 0)

func _on_start_animation_body_entered(body: Node2D) -> void:
	%Papelito.checkpoint.selected = false
	%Papelito.checkpoint = self
	self.selected = true
