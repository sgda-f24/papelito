extends Node2D
class_name Checkpoint

@onready var outline_shader = preload("res://entities/outline.gdshader")
@onready var animation: AnimatedSprite2D = %AnimatedSprite2D

@export var selected = false
@export var amplitude = 0.25
@export var frequency = 0.001

func _process(delta: float) -> void:
	position.y += sin(Time.get_ticks_msec()*frequency) * amplitude	
	if selected:
		animation.material.set_shader_parameter("width", sin(Time.get_ticks_msec()*frequency)+2.)
	else:
		animation.material.set_shader_parameter("width", 0)

func _on_start_animation_body_entered(body: Node2D) -> void:
	%Papelito.checkpoint.selected = false
	%Papelito.checkpoint = self
	self.selected = true
	animation.play()


func _on_start_animation_body_exited(body: Node2D) -> void:
	animation.stop()
