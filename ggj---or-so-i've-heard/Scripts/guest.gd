class_name Guest
extends Sprite2D

var mask_data: Dictionary = {
	"decor": ["crest", "rhinestones", "tears", "stitches", "centre"],
	"colors": {
		"silver":"255,255,255",
		"ruby":"138,23,48",
		"sapphire":"31,66,161",
		"emerald":"0,199,47",
		"amethyst":"164,55,212",
		"aquamarine":"39,200,221",
		"topaz":"208,181,26",
		"onyx":"30,30,30"
	}
}

## randomly genned upon instantiation
var mask: Dictionary[String, String] = {}
var speed: float

## set by the game manager
var rumors: Array[String] = []
var moving: bool = true
var approach_state: int = 0
var approach_progress: float = 0
var room_position: Vector2
var room_scale: Vector2
# debug helper
var is_poi: bool = false

@onready var camera: Camera2D = $/root/root/Camera2D

func _ready() -> void:
	populate_mask()
	# get a randomized set of speeds
	var choices = []
	for i in range(100):
		choices.append(randf_range(0.3,7.5))
	# then pick one
	self.speed = choices.pick_random()
	if randi()%2 == 0: self.speed *= -1.0

	# button shit
	$Button.pressed.connect(self.button_press)
	$Button.disabled = true
func _process(delta: float) -> void:
	$DialogueIndicator.visible = self.rumors != []
	$POIIndicator.visible = self.is_poi
	# handle approaching motion
	if approach_state != 0:
		handle_approaching(delta)
	
	# moving around the room
	if moving:
		var t = Time.get_ticks_msec() / 1000.0
		var dir = Vector2(sin(t), cos(t)) * 10
		self.position += dir * (self.speed * delta)
		self.rotation = sin(t + self.speed) / 5 

func button_press():
	# animate moving to center-screen
	moving = false
	room_position = self.global_position
	room_scale = self.scale
	approach_state = 1
	
	# signal the game manager to do gamevar-dependent stuff
	$/root/root.on_guest_pressed(self)

func populate_mask():
	"randomly generate the details of a guest's mask."
	# pick features randomly
	mask_data["decor"].shuffle()
	var n = randi()%2 +2 # 2-4
	if randi()% 7 == 0:
		n += 1 # and rarely, 5
	#pick the first n of the shuffled list
	var feats = mask_data["decor"].slice(0, n+1)
	
	for feature in feats:
		# decide a color for the mask feature
		var colors = mask_data["colors"].keys()
		var color: String = colors[randi()%len(colors)]
		self.mask[feature] = color
		# do sprite config stuff based on mask deets
		var as_vec = mask_data["colors"][color].split(",")
		as_vec = Color(int(as_vec[0])/255.0, int(as_vec[1])/255.0, int(as_vec[2])/255.0)
		self.find_child(feature).visible = true
		self.find_child(feature).modulate = as_vec

func handle_approaching(delta):
	if approach_state == 1:
		approach_progress += delta*2
		if approach_progress > 1.0:
			approach_progress = 1.0
			approach_state = 0
			on_finished_approach(true)
	elif approach_state == -1:
		approach_progress -= delta*2
		if approach_progress < 0.0:
			approach_progress = 0.0
			approach_state = 0
			on_finished_approach(false)
	
	# tween position
	self.global_position = lerp(room_position, camera.get_screen_center_position(), clampf(approach_progress, 0.0, 1.0))
	# tween rotation
	self.rotation = lerp(self.rotation, 0.0, approach_progress)
	# tween scale
	self.scale = lerp(room_scale, room_scale*4, approach_progress)
func on_finished_approach(toggle: bool) -> void:
	if toggle:
		# signal the game manager to do gamevar-dependent stuff
		$/root/root.on_guest_approached(self)
	else:
		self.moving = true
		# signal the game manager to do gamevar-dependent stuff
		$/root/root.on_guest_left(self)
