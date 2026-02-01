extends Node

func gen_poi_dialogue(poi_reason: String) -> String:
	"get some dialogue that details a guest's person of interest."
	var gen = ""
	var i = randi()%len(mask_dialogue["describe_reason_prelude"])
	gen += mask_dialogue["describe_reason_prelude"][i] + " "
	
	i = randi()%len(mask_dialogue["poi_reasons"][poi_reason])
	gen += mask_dialogue["poi_reasons"][poi_reason]
	return gen

func gen_rumor_positive() -> String:
	"get a rumor in the form 'has these things on their mask'."
	return ""

var mask_dialogue = {
	"describe_reason_prelude":[
		"A fellow at this party has",
		"Someone at this party has",
		"One of the partygoers has"
	],
	"poi_reasons":{
		"love":[
			"charmed me beyond what I'd usually admit.",
			"given me the cold shoulder, and I must bid their heart once more!",
		],
		"thief":[
			"stolen my necklace!",
			"been stealing from the other guests."
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
			"similarities to my own."
		],
		"unique":[
			"worn by no other partygoer at the ball."
		]
	}
}
