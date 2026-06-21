extends CharacterBody2D

@export var mass: float = 1
@export var parent: ParentBody
@export var motion: Vector2 = Vector2(0, 0)

@export var al: float # inverse of semi-major axis 
#(to make hyperbolic orbits not div by zero error)
@export var e: float # eccentricity
@export var w: float # argument of periapsis

@onready var G: float = 1 #gravitational constant
@onready var mu: float = G * parent.mass

@onready var rel_pos: Vector2 = global_position - parent.global_position

func _physics_process(delta: float) -> void:
	calc_orbit()
	prediction_problem(delta)


func calc_orbit():
	rel_pos = global_position - parent.global_position # position relative to parent
	var r: float = rel_pos.length() # current radius from parent
	var v2: float = velocity.length_squared() # (use in next eq)
	var e_vec: Vector2 = (1/mu)*(((v2 - (mu/r))*rel_pos) - (velocity*(rel_pos.dot(velocity)))) # eccentricity vector
	e = e_vec.length()
	var h: float = velocity.cross(rel_pos) # angular momentum vector (probably unnecessary)
	var p: float = h**2 / mu # semi latus rectum (probably unnecessary)
	al = ((2*mu)/(r-v2)) / mu
	w = (Vector2(1,0).dot(e_vec)) / (e_vec.length())


func prediction_problem(delta: float):
	# we got uhhhhh vectors v1 (velocity), r1 (rel_pos), dt (delta), and parameters
	# find vectors v2 r2 then return them
	# then main _physics_process can move to new r2 and update v2??
	# not move_and_slide. that wont be accurate enough. probably
	var r: float = rel_pos.length() # current radius from parent
	var cosE: float = (1 - (r * al)) / e
	var sinE: float = (rel_pos.dot(velocity)) / sqrt(mu * (1/al))
	var x: float = sqrt(mu) * al # * time since periapsis
	var z: float = x**2 * al
	var dtdx: float = r / sqrt(mu)
	var x2: float = x + (delta / dtdx)
