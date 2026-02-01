extends Sprite2D

var mask_data = {
	"decor": ["crest", "rhinestones", "tears", "stitches"],
	"colors": {
		"silver":"255,255,255",
		"ruby":"255,0,0",
		"sapphire":"0,0,255",
		"emerald":"0,255,0",
		"amethyst":"0,0,0",
		"turqoise":"0,255,0",
	}
}

# randomly genned upon instantiation
@export var mask_features: Dictionary[String, String] = {}

# nullable, assigned by game manager
@export var person_of_interest: Node
@export var dialogue: Array[String] 

func _ready() -> void:
	mask_data["decor"].shuffle()
	var feats = randi()%2 +2 # 2-4
	feats = mask_data["decor"].slice(0, feats+1)
	for feature in feats:
		var colors = mask_data["colors"].keys()
		var color = colors[randi()%len(colors)]
		self.mask_features[feature] = color
	# do sprite config stuff based on mask deets
	print(self.mask_features)
