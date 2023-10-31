class_name ParticleCloud
extends CPUParticles2D


func _ready():
	amount = 10
	lifetime = 0.7
	explosiveness = 0.03
	randomness = 0.45
	emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	emission_sphere_radius = 19.8
	direction = Vector2(0,0)
	gravity = Vector2(0,-98)
	position = Vector2(0,5)
	emitting = true
