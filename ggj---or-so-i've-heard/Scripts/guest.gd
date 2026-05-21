extends Sprite2D

var mask_data = {
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

# randomly genned upon instantiation
var mask: Dictionary[String, String] = {}
var motion

# set by the game manager
var rumors: Array[String] = []

func _ready() -> void:
	mask_data["decor"].shuffle()
	var feats = randi()%2 +2 # 2-4
	if randi()% 7 == 0:
		feats += 1 # and rarely, 5
	feats = mask_data["decor"].slice(0, feats+1)
	
	$crest.show_behind_parent = true
	var choices = []
	for i in range(100):
		choices.append(randf_range(0.3,7.5))
	self.motion = choices.pick_random()
	if randi()%2 == 0: self.motion = -self.motion

	for feature in feats:
		var colors = mask_data["colors"].keys()
		var color: String = colors[randi()%len(colors)]
		self.mask[feature] = color
		# do sprite config stuff based on mask deets
		var as_vec = mask_data["colors"][color].split(",")
		as_vec = Color(int(as_vec[0])/255.0, int(as_vec[1])/255.0, int(as_vec[2])/255.0)
		self.find_child(feature).visible = true
		self.find_child(feature).modulate = as_vec
		# button shit
		$Button.pressed.connect(self.button_press)

func _process(delta: float) -> void:
	if self.rumors != []:
		$DialogueIndicator.visible = true
	else:
		$DialogueIndicator.visible = false
	# moving around the room
	if self == $/root/root/Guest: return
	
	var t = Time.get_ticks_msec() / 1000.0
	var dir = Vector2(sin(t), cos(t)) * 10
	self.position += dir * (self.motion * delta)
	self.rotation = sin(t + self.motion) / 5 

func button_press():
	$/root/root.on_guest_pressed(self)
	
