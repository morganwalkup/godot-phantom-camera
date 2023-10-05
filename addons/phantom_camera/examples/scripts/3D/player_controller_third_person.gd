extends "player_controller.gd"

@onready var _aim_pcam: PhantomCamera3D = %PlayerAimPhantomCamera3D
@onready var _model: Node3D = $PlayerModel

@export var mouse_sensitivity: float = 0.05

@export var min_yaw: float = -89.9
@export var max_yaw: float = 50

@export var min_pitch: float = 0
@export var max_pitch: float = 360



func _ready() -> void:
	super()

	if _player_pcam.get_follow_mode() == _player_pcam.Constants.FollowMode.THIRD_PERSON:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	super(delta)
	
	if velocity.length() > 0.2:
		var look_direction: Vector2 = Vector2(velocity.z, velocity.x)
		_model.rotation.y = look_direction.angle()


func _unhandled_input(event: InputEvent) -> void:
	if _player_pcam.get_follow_mode() == _player_pcam.Constants.FollowMode.THIRD_PERSON:
		var active_pcam: PhantomCamera3D
		
		if is_instance_valid(_aim_pcam):
			_set_pcam_rotation(_player_pcam, event)
			_set_pcam_rotation(_aim_pcam, event)
			if _player_pcam.get_priority() > _aim_pcam.get_priority():
				_toggle_aim_pcam(event)
			else:
				_toggle_aim_pcam(event)

func _set_pcam_rotation(pcam: PhantomCamera3D, event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var pcam_rotation_degrees: Vector3
		pcam_rotation_degrees = pcam.get_third_person_rotation_degrees()
		pcam_rotation_degrees.x -= event.relative.y * mouse_sensitivity
		pcam_rotation_degrees.x = clamp(pcam_rotation_degrees.x, min_yaw, max_yaw)

		pcam_rotation_degrees.y -= event.relative.x * mouse_sensitivity
		pcam_rotation_degrees.y = wrapf(pcam_rotation_degrees.y, min_pitch, max_pitch)
	
		pcam.set_third_person_rotation_degrees(pcam_rotation_degrees)


func _toggle_aim_pcam(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 2:
		if _player_pcam.get_priority() > _aim_pcam.get_priority():
			_aim_pcam.set_priority(30)
		else:
			_aim_pcam.set_priority(0)
