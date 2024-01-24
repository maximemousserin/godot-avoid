extends Node3D

var _random_time: int = randi_range(5,8)
var _random_enemies = []
var _wave_time_elapsed = 0
var enemies = []
var current_enemies = []
var six_enemies_wave_timeout = 4
var game_speed = 1
var game_speed_increase_timeout = 4
var game_speed_time_elapsed = 0

func _ready():
	enemies = $Enemies.get_children()

func _process(delta):
	_process_enemies_waves(delta)
	_process_game_speed_increase(delta)

func _process_game_speed_increase(delta):
	game_speed_time_elapsed += delta * (1.0 / float(game_speed_increase_timeout))
	if game_speed_time_elapsed >= 1:
		game_speed_time_elapsed -= 1
		if game_speed < 4:
			game_speed += 0.1
			print("new game speed")
			for x in enemies:
				x.set_animation_player_speed(game_speed)

func _process_enemies_waves(delta):
	_wave_time_elapsed += delta * (1.0 / float(_random_time))
	if _wave_time_elapsed >= 1:
		_wave_time_elapsed -= 1
		_random_time = randi_range(5,8)
		print("random time: %s" % _random_time)
		select_current_enemies()
		start_current_enemies_wave()

func select_current_enemies():
	current_enemies = []
	var nb_enemies_wave: int = randi_range(3, 4)
	if six_enemies_wave_timeout > 0:
		six_enemies_wave_timeout -= 1
	else:
		nb_enemies_wave = 6
		six_enemies_wave_timeout = 4
	while current_enemies.size() < nb_enemies_wave:
		var enemy = enemies.pick_random()
		if !current_enemies.has(enemy):
			current_enemies.append(enemy)
	print(current_enemies)
	
func start_current_enemies_wave():
	for x in current_enemies:
		x.fall()
