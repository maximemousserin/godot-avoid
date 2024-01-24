class_name CharacterSkin
extends Node3D

# False : set animation to "idle"
# True : set animation to "move"
@onready var moving : bool = false : set = set_moving

func _ready():
	$AnimationPlayer.play("Idle")

func set_moving(value : bool):
	moving = value
	if moving:
		$AnimationPlayer.play("Running_A")
	else:
		$AnimationPlayer.play("Idle")

func jump():
	$AnimationPlayer.play("Jump_Full_Long")
	pass
 

func fall():
	$AnimationPlayer.play("Jump_Idle")
	pass
