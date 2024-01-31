extends CharacterBody2D

@export var movement_target_position: Vector2

const SPEED: float = 100.0
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	# Make sure to not await during _ready.
	call_deferred("actor_setup")
	navigation_agent.velocity_computed.connect(Callable(_on_velocity_computed))


func actor_setup() -> void:
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	navigation_agent.target_position = movement_target_position


func _physics_process(delta: float) -> void:
	if navigation_agent.is_navigation_finished():
		return

	var current_agent_position: Vector2 = global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 =	global_position.direction_to(next_path_position) * SPEED

	if navigation_agent.avoidance_enabled:
		navigation_agent.velocity = new_velocity
	else:
		_on_velocity_computed(new_velocity)

	velocity = current_agent_position.direction_to(next_path_position) * SPEED
	move_and_slide()


func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
