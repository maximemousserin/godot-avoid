class_name Enemy
extends Node3D

func fall():
	$AnimatableBody3D/AnimationPlayer.play("fall")

func set_animation_player_speed(value):
	if value < 4:
		$AnimatableBody3D/AnimationPlayer.set_speed_scale(value)
