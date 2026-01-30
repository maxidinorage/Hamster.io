extends CharacterBody3D

var movement_speed: float = 5.0
var movement_target_position: Vector3 = Vector3(0.0,0.0,00.0)
var food = 50
var idle = true
var moving = false
var closest_seed = null
var min_distance = INF

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	# These values need to be adjusted for the actor's speed
	# and the navigation layout.
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5

	# Make sure to not await during _ready.
	actor_setup.call_deferred()

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame

	# Now that the navigation map is no longer empty, set the movement target.
	set_movement_target(movement_target_position)

func set_movement_target(movement_target: Vector3):
	navigation_agent.set_target_position(movement_target)

func _physics_process(_delta):
	#finding a new path

	idle = true
	moving = false
	if food <= 50:
		closest_seed = null
		min_distance = INF
		#Find the closest seed
		
		for seed in get_tree().get_nodes_in_group("Seeds"):
			if seed:
				var distance_to_seed = global_position.distance_to(seed.global_position)
				if distance_to_seed <= min_distance:
					closest_seed = seed
					min_distance = distance_to_seed
		
		#Move to the closest available seed
		if closest_seed :
			set_movement_target(closest_seed.global_position)
		idle = false
		moving = true
	if navigation_agent.is_navigation_finished():
		return
	#set the next path 
	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()
	# look to the objective
	if current_agent_position.distance_to(next_path_position) > 0.01:
		look_at(next_path_position, Vector3.UP)
	#calculing the velocity
	velocity = current_agent_position.direction_to(next_path_position) * movement_speed

	move_and_slide()
