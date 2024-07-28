extends RigidBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	self.angular_velocity.x = clamp(self.angular_velocity.x,0.0,0.1)
	self.angular_velocity.y = clamp(self.angular_velocity.y,0.0,0.1)
	self.angular_velocity.z = clamp(self.angular_velocity.z,0.0,0.1)
