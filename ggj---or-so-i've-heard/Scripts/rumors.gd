extends Node

func gen_poi_dialogue(poi_reason: String) -> String:
	"get some dialogue that details a guest's person of interest."
	var genned = ""
	var i = randi()%len(mask_dialogue["describe_reason_prelude"])
	genned += mask_dialogue["describe_reason_prelude"][i] + " "
	
	i = randi()%len(mask_dialogue["poi_reasons"][poi_reason])
	genned += mask_dialogue["poi_reasons"][poi_reason][i]
	return genned

func gen_hint_positive(feature: String, color: String) -> String:
	"get a rumor in the form 'has these things on their mask'."
	var genned = ""
	var i = randi()%len(mask_dialogue["describe_mask_prelude"])
	genned += mask_dialogue["describe_mask_prelude"][i] + " "
	
	i = randi()%len(mask_dialogue["features"][feature])
	genned += mask_dialogue["features"][feature][i] + " "
	genned += color +" "+feature+"."
	return genned
func gen_hint_similar():
	return
var mask_dialogue = {
	"describe_reason_prelude":[
		"A fellow at this party has",
		"Someone at this party has",
		"One of the partygoers has"
	],
	"poi_reasons":{
		"love":[
			"charmed me beyond what I'd usually admit. I simply must be reunited with them!",
			"given me the cold shoulder, and I must bid their heart once more!",
		],
		"thief":[
			"stolen my necklace! I'd like your help finding the culprit and getting it back.",
			"been stealing from the other guests. I've gotten permission to investigate, and you of course are the best person to help..."
		],
		"murder":[
			"committed the cold-blooded killing of another guest."
		]
	},
	"describe_mask_prelude":[
		"Their mask had",
		"The mask they wore had",
		"On their mask, there was",
	],
	"features":{
		"crest":[
			"an unmistakable",
			"a"
		],
		"rhinestones":[
			"an array of brilliant",
			"a dazzling set of",
			"a shining line of"
		],
		"stitches":[
			"some eye-catching",
			"a sprinkle of",
			"a "
		]
	},
	"features_meta":{
		"similar_to_speaker":[
			"details which match my own mask.",
			"similarities to my own.",
			"bedazzlements that are also present on this one."
		],
		"unique":[
			"worn by no other partygoer at the ball.",
			"of a color unique to them. No other guests had that color."
		]
	},
	"rumor_leadin":[
		"Why, yes I do. Come, come...!",
		"As a matter of fact... this way - and check for followers, will you?"
	],
	"no_rumors":[
		"Sorry, friend. I've not anything for you.",
		"Hmm... well, they certainly wore a mask. Does that help?"
	]
}
