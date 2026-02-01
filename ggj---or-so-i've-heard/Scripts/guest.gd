extends Sprite2D

var mask_data = {
	"decor": ["crest", "rhinestones", "tears", "stitches", "centre"],
	"colors": {
		"silver":"255,255,255",
		"ruby":"255,0,0",
		"sapphire":"0,0,255",
		"emerald":"0,255,0",
		"amethyst":"255,0,255",
		"aquamarine":"0,255,255",
		"topaz":"255,255,0",
		"onyx":"25,25,25"
	}
}

# randomly genned upon instantiation
var mask: Dictionary[String, String] = {}

# set by the game manager
var rumors: Array[String] = []

func _ready() -> void:
	mask_data["decor"].shuffle()
	var feats = randi()%2 +2 # 2-4
	if randi()% 3 == 1:
		feats += 1
	feats = mask_data["decor"].slice(0, feats+1)
	
	for feature in feats:
		var colors = mask_data["colors"].keys()
		var color: String = colors[randi()%len(colors)]
		self.mask[feature] = color
		var as_vec = mask_data["colors"][color].split(",")
		as_vec = Color(int(as_vec[0]), int(as_vec[1]), int(as_vec[2]))
		self.find_child(feature).visible = true
		self.find_child(feature).modulate = as_vec
	# do sprite config stuff based on mask deets

func _process(delta: float) -> void:
	if self.rumors != []:
		$DialogueIndicator.visible = true
	else:
		$DialogueIndicator.visible = false
		
