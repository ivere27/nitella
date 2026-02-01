package pairing

import (
	"crypto/rand"
	"fmt"
	"math/big"
	"strings"
)

// EFF short wordlist (subset) - easy to pronounce, no similar words
// Full list: https://www.eff.org/dice
var wordlist = []string{
	"acid", "acorn", "acre", "acts", "afar", "aged", "agent", "ajar",
	"alarm", "album", "alert", "alike", "alive", "aloe", "aloft", "aloha",
	"alone", "amaze", "amber", "amigo", "amino", "ample", "angel", "angry",
	"ankle", "apple", "april", "apron", "aqua", "arena", "argue", "arise",
	"armor", "army", "aroma", "array", "arrow", "art", "asset", "atom",
	"attic", "audio", "aunt", "avoid", "awake", "award", "away", "axis",
	"bacon", "badge", "bagel", "baker", "balmy", "bamboo", "banjo", "barn",
	"bash", "basil", "baton", "beach", "beast", "bee", "begin", "being",
	"belly", "below", "bench", "best", "bird", "birth", "black", "blade",
	"blank", "blast", "blaze", "blend", "bless", "blimp", "blind", "bliss",
	"block", "blog", "blond", "blood", "bloom", "blown", "blue", "blunt",
	"boat", "body", "boil", "bolt", "bomb", "bone", "bonus", "book",
	"booth", "boots", "boss", "botch", "both", "boxer", "brain", "branch",
	"brand", "brass", "brave", "bread", "break", "breed", "brick", "bride",
	"brief", "bring", "brink", "brisk", "broad", "broil", "broke", "brook",
	"broom", "brush", "buck", "bud", "buggy", "build", "bulge", "bulk",
	"bunny", "burn", "burst", "bus", "bush", "bust", "busy", "buzz",
	"cabin", "cable", "cache", "cadet", "cage", "cake", "calm", "camel",
	"camp", "candy", "canon", "cape", "card", "cargo", "carol", "carry",
	"carve", "case", "cash", "cast", "castle", "catch", "cause", "cave",
	"cease", "cedar", "chain", "chair", "champ", "charm", "chart", "chase",
	"cheap", "check", "cheek", "cheer", "chess", "chest", "chew", "chief",
	"child", "chill", "chimp", "chip", "chomp", "chord", "chore", "chunk",
	"cider", "cigar", "cinch", "city", "civic", "civil", "claim", "clamp",
	"clap", "clash", "clasp", "class", "claw", "clay", "clean", "clear",
	"clerk", "click", "cliff", "climb", "cling", "clip", "cloak", "clock",
	"clone", "close", "cloth", "cloud", "clown", "club", "cluck", "clue",
	"coach", "coast", "coat", "cobra", "cocoa", "code", "coil", "coin",
	"cola", "cold", "comet", "comic", "comma", "cone", "coral", "cork",
	"corn", "cost", "couch", "cough", "cover", "cozy", "craft", "cramp",
	"crane", "crash", "crate", "crawl", "crazy", "cream", "creek", "creep",
	"crisp", "crook", "crop", "cross", "crowd", "crown", "crush", "crust",
	"cube", "cult", "cupid", "cure", "curl", "curry", "curse", "curve",
	"cycle", "daisy", "dance", "dare", "dark", "dart", "dash", "data",
	"date", "dawn", "deals", "dean", "decay", "deck", "decor", "decoy",
	"deed", "delay", "delta", "deluxe", "demon", "denim", "dense", "dent",
	"depth", "derby", "desk", "dial", "diary", "dice", "diner", "disco",
	"dish", "disk", "ditch", "diver", "dizzy", "dock", "dodge", "doing",
	"doll", "dome", "donor", "donut", "doom", "door", "dork", "dorm",
	"dose", "dot", "double", "doubt", "dough", "dove", "down", "dozen",
	"draft", "drain", "drama", "drank", "drape", "draw", "dread", "dream",
	"dress", "dried", "drift", "drill", "drink", "drip", "drive", "drone",
	"drool", "drop", "drove", "drown", "drum", "dry", "duck", "dude",
	"dug", "duke", "dull", "dummy", "dump", "dune", "dunk", "duo",
	"dusk", "dust", "duty", "dwarf", "dwell", "eagle", "earth", "easel",
	"east", "eaten", "eater", "echo", "edge", "eel", "eight", "elbow",
	"elder", "elite", "elm", "elope", "elude", "elves", "email", "ember",
	"emit", "empty", "emu", "enter", "entry", "equal", "equip", "erase",
	"error", "erupt", "essay", "eve", "even", "event", "every", "exact",
	"exam", "exile", "exist", "exit", "extra", "fable", "faced", "fact",
	"fade", "fail", "faint", "fairy", "faith", "fake", "fall", "fame",
	"fancy", "fang", "far", "farm", "fatal", "favor", "fawn", "feast",
	"feed", "feel", "fence", "fend", "fern", "ferry", "fetch", "fever",
	"fiber", "field", "fifth", "fifty", "film", "filth", "final", "finch",
	"find", "fine", "fire", "firm", "first", "fish", "fist", "five",
	"fix", "flag", "flake", "flame", "flap", "flask", "flat", "flavor",
	"flaw", "flax", "fled", "flesh", "flex", "flick", "flip", "flit",
	"float", "flock", "flood", "floor", "flop", "floss", "flour", "flow",
	"flu", "fluff", "fluid", "fluke", "flung", "flunk", "flush", "flute",
	"foam", "focal", "focus", "fog", "foil", "folk", "fond", "font",
	"food", "fool", "foot", "force", "forge", "fork", "form", "fort",
	"forum", "fossil", "found", "fox", "foyer", "frail", "frame", "frank",
	"fraud", "freak", "fresh", "fried", "frog", "from", "front", "frost",
	"froth", "frown", "froze", "fruit", "fudge", "fuel", "fully", "fumes",
	"fund", "funny", "fur", "fury", "fuse", "fussy", "futon", "future",
	"fuzzy", "giant", "gift", "gills", "given", "giver", "glad", "glass",
	"globe", "gloom", "glory", "gloss", "glove", "glow", "glue", "goal",
	"goat", "going", "gold", "golf", "gong", "good", "goofy", "goose",
	"grape", "graph", "grasp", "grass", "grave", "gravy", "gray", "greed",
	"green", "greet", "grew", "grief", "grill", "grim", "grin", "grind",
	"grip", "grit", "groan", "groom", "gross", "group", "grout", "grove",
	"growl", "grown", "grub", "grunt", "guard", "guess", "guest", "guide",
	"guild", "guilt", "gulf", "gulp", "gummy", "guru", "gust", "habit",
	"hair", "half", "hall", "halo", "halt", "hang", "happy", "harm",
	"harsh", "haste", "hasty", "hatch", "hate", "haunt", "haven", "hazel",
	"hazy", "head", "heal", "heap", "heart", "heat", "heavy", "hedge",
	"hefty", "held", "helix", "hello", "help", "hemp", "hence", "herb",
	"herd", "hero", "hers", "hick", "hide", "high", "hike", "hill",
	"hilly", "hinge", "hippo", "hire", "hiss", "hitch", "hive", "hobby",
	"hoist", "hold", "hole", "holly", "home", "honey", "honor", "hood",
	"hook", "hop", "hope", "horn", "horse", "host", "hotel", "hound",
	"house", "hover", "howl", "hub", "hug", "hull", "human", "humid",
	"humor", "hump", "hunch", "hung", "hunk", "hunt", "hurry", "hurt",
	"hush", "husky", "hut", "hydro", "hyena", "hymn", "icing", "icon",
	"idea", "ideal", "idiom", "idiot", "idle", "idly", "igloo", "image",
	"imp", "inch", "index", "inbox", "indie", "info", "ink", "inner",
	"input", "intro", "ion", "iron", "islam", "issue", "itch", "item",
	"ivory", "ivy", "jab", "jack", "jade", "jaded", "jam", "jaws",
	"jazz", "jeans", "jeep", "jelly", "jerk", "jet", "jiffy", "job",
	"jog", "join", "joke", "joker", "jolly", "jolt", "joy", "judge",
	"juice", "juicy", "july", "jumbo", "jump", "jumpy", "june", "jungle",
	"junk", "juror", "jury", "just", "karma", "kayak", "keen", "keep",
	"kept", "kick", "kid", "king", "kiosk", "kiss", "kite", "kitty",
	"kiwi", "knee", "knelt", "knife", "knit", "knock", "knot", "known",
	"koala", "label", "labor", "lace", "lack", "lad", "laden", "ladle",
	"lady", "laid", "lake", "lamb", "lame", "lamp", "lance", "land",
	"lane", "lap", "lapel", "large", "lasso", "last", "late", "later",
	"latex", "lathe", "latte", "laugh", "lava", "lawn", "layer", "lazy",
	"lead", "leaf", "leak", "lean", "leap", "learn", "lease", "leash",
	"least", "leave", "ledge", "leech", "left", "legal", "lemon", "lend",
	"lens", "lent", "level", "lever", "lid", "life", "lift", "light",
	"lilac", "lily", "limb", "lime", "limit", "limp", "line", "link",
	"lion", "lip", "list", "lit", "liter", "live", "liver", "llama",
	"load", "loaf", "loan", "lobby", "lobe", "local", "lock", "lodge",
	"loft", "lofty", "logic", "logo", "lone", "long", "look", "loop",
	"loot", "lord", "lose", "loss", "lost", "lotus", "loud", "love",
	"lower", "loyal", "luck", "lucky", "lump", "lunar", "lunch", "lung",
	"lurch", "lure", "lurk", "lush", "lying", "lyric", "macro", "madam",
	"made", "magic", "magma", "maid", "mail", "main", "major", "maker",
	"mango", "manor", "many", "map", "maple", "march", "marry", "marsh",
	"mask", "mass", "mast", "match", "mate", "math", "mayor", "maze",
	"meal", "mean", "meat", "medal", "media", "meek", "meet", "melon",
	"melt", "memo", "mend", "menu", "mercy", "merge", "merit", "merry",
	"mesh", "messy", "metal", "metro", "might", "mild", "milk", "mimic",
	"mind", "mint", "minus", "mist", "mitch", "mitten", "mix", "moan",
	"moat", "mob", "mock", "model", "moist", "mold", "mole", "mom",
	"monk", "month", "moody", "moon", "moose", "mop", "moral", "morse",
	"moss", "most", "moth", "motor", "motto", "mound", "mouse", "mouth",
	"move", "movie", "mow", "much", "mud", "mug", "mulch", "mule",
	"mull", "mumps", "munch", "mural", "murky", "muse", "music", "mute",
	"nacho", "nag", "nail", "naive", "name", "nap", "navy", "near",
	"neat", "neck", "need", "nerve", "nest", "net", "never", "next",
	"niece", "night", "nimble", "nine", "noble", "nod", "noise", "nomad",
	"none", "nook", "noon", "noose", "norm", "north", "nose", "notch",
	"note", "novel", "nudge", "nuke", "numb", "nurse", "nut", "nylon",
	"oasis", "oat", "obey", "ocean", "octet", "odds", "odor", "offer",
	"often", "oink", "omen", "onion", "onset", "open", "opera", "opt",
	"orbit", "order", "organ", "other", "otter", "ounce", "outer", "oval",
	"oven", "owl", "own", "owner", "oxide", "oxygen", "oyster", "pace",
	"pack", "pad", "pagan", "page", "paid", "pail", "pain", "pair",
	"palm", "panda", "panic", "pants", "paper", "par", "park", "party",
	"pasta", "paste", "patch", "path", "patio", "pause", "pave", "paw",
	"pay", "peace", "peach", "peak", "pear", "pearl", "pecan", "pedal",
	"peek", "peel", "peep", "pelican", "pen", "penny", "pep", "perch",
	"perk", "perky", "permit", "pest", "petal", "petty", "photo", "piano",
	"pick", "pie", "piece", "pier", "pig", "piggy", "pile", "pilot",
	"pinch", "pine", "ping", "pink", "pinky", "pint", "pious", "pipe",
	"pit", "pitch", "pity", "pivot", "pixel", "pizza", "place", "plaid",
	"plain", "plan", "plane", "plank", "plant", "plate", "play", "plaza",
	"plea", "plead", "plot", "plow", "pluck", "plug", "plum", "plumb",
	"plume", "plump", "plunge", "plus", "plush", "poach", "pod", "poem",
	"poet", "point", "poise", "poker", "polar", "pole", "polish", "polka",
	"polo", "pond", "pony", "pooch", "pool", "poor", "pop", "poppy",
	"porch", "pork", "port", "pose", "posh", "post", "pouch", "pound",
	"pour", "pout", "power", "prank", "prawn", "pray", "press", "price",
	"pride", "prime", "print", "prism", "prize", "probe", "promo", "proof",
	"prose", "proud", "prowl", "prude", "prune", "pry", "pub", "puck",
	"puff", "pull", "pulp", "pulse", "pump", "punch", "punk", "pupil",
	"puppy", "pure", "purge", "purple", "purse", "push", "putt", "puzzle",
	"quack", "quake", "qualm", "quart", "queen", "query", "quest", "quick",
	"quiet", "quilt", "quirk", "quit", "quote", "rabbi", "race", "rack",
	"radar", "radio", "raffle", "raft", "rage", "raid", "rail", "rain",
	"raise", "rally", "ramp", "ranch", "range", "rank", "rapid", "rare",
	"rash", "raspy", "rat", "rate", "rave", "raven", "raw", "ray",
	"razor", "reach", "react", "read", "ready", "real", "realm", "reap",
	"rebel", "recap", "red", "reef", "reel", "refer", "rehab", "reign",
	"relax", "relay", "relic", "remix", "repay", "repel", "reply", "report",
	"reset", "rest", "retro", "retry", "return", "reveal", "review", "revolt",
	"rhino", "rhyme", "rice", "rich", "ride", "rider", "ridge", "rifle",
	"rift", "right", "rigid", "ring", "rinse", "riot", "ripe", "ripen",
	"rise", "risk", "risky", "rival", "river", "roach", "road", "roam",
	"roar", "roast", "robe", "robin", "robot", "rock", "rocky", "rod",
	"rode", "rodeo", "rogue", "role", "roman", "romp", "roof", "room",
	"roost", "root", "rope", "rose", "rosy", "rot", "rotten", "rough",
	"round", "route", "rover", "royal", "rub", "ruby", "rude", "rugby",
	"ruin", "rule", "ruler", "rumor", "run", "rung", "rural", "rush",
	"rust", "rusty", "rut", "sacred", "sad", "safe", "sage", "said",
	"sail", "saint", "sake", "salad", "sale", "salon", "salt", "salty",
	"salute", "same", "sand", "sandy", "sane", "sang", "sank", "sap",
	"sassy", "sauce", "sauna", "save", "savor", "scale", "scalp", "scam",
	"scan", "scar", "scare", "scarf", "scary", "scene", "scent", "school",
	"scope", "score", "scorn", "scout", "scowl", "scrap", "screen", "screw",
	"scrub", "seal", "seam", "search", "season", "seat", "second", "secret",
	"sector", "see", "seed", "seek", "seem", "seize", "self", "sell",
	"semi", "send", "sense", "sent", "serum", "serve", "set", "setup",
	"seven", "sever", "shade", "shadow", "shaft", "shake", "shall", "sham",
	"shame", "shape", "share", "shark", "sharp", "shave", "shed", "sheep",
	"sheer", "sheet", "shelf", "shell", "shift", "shimmer", "shin", "shine",
	"shiny", "ship", "shirt", "shock", "shoe", "shook", "shoot", "shop",
	"shore", "short", "shot", "shout", "shove", "show", "showy", "shred",
	"shrub", "shrug", "shuck", "shun", "shut", "shy", "sick", "side",
	"sift", "sigh", "sight", "sign", "silk", "silky", "sill", "silly",
	"silver", "simple", "since", "sing", "sink", "sip", "siren", "sister",
	"sit", "site", "six", "size", "skate", "sketch", "ski", "skid",
	"skill", "skin", "skinny", "skip", "skirt", "skull", "sky", "slab",
	"slack", "slam", "slang", "slant", "slap", "slash", "slate", "slave",
	"sled", "sleek", "sleep", "sleet", "slept", "slice", "slick", "slide",
	"slim", "slime", "slimy", "sling", "slip", "slit", "slob", "slope",
	"slot", "slow", "slug", "slum", "slump", "slung", "slur", "slush",
	"small", "smart", "smash", "smell", "smelt", "smile", "smirk", "smock",
	"smog", "smoke", "smoky", "smooth", "snack", "snag", "snail", "snake",
	"snap", "snare", "snarl", "snatch", "sneak", "sneer", "sniff", "snore",
	"snort", "snout", "snow", "snowy", "snub", "snug", "soak", "soap",
	"soar", "sob", "sober", "social", "sock", "sod", "soda", "sofa",
	"soft", "soggy", "soil", "solar", "sold", "sole", "solid", "solo",
	"solve", "some", "son", "song", "sonic", "soon", "soot", "soothe",
	"sorry", "sort", "soul", "sound", "soup", "sour", "south", "sow",
	"space", "spade", "spam", "span", "spare", "spark", "spasm", "spawn",
	"speak", "spear", "spec", "speed", "spell", "spend", "spent", "spew",
	"spice", "spicy", "spider", "spike", "spill", "spin", "spine", "spiral",
	"spirit", "spit", "spite", "splash", "split", "spoil", "spoke", "spoof",
	"spook", "spool", "spoon", "sport", "spot", "spray", "spread", "spree",
	"spring", "sprout", "spruce", "spud", "spun", "spur", "spy", "squad",
	"squat", "squawk", "squeak", "squid", "stab", "stack", "staff", "stage",
	"stain", "stair", "stake", "stale", "stalk", "stall", "stamp", "stand",
	"stank", "star", "stare", "stark", "start", "stash", "state", "statue",
	"stay", "steak", "steal", "steam", "steel", "steep", "steer", "stem",
	"step", "stern", "stew", "stick", "sticky", "stiff", "still", "sting",
	"stink", "stint", "stir", "stock", "stoic", "stomp", "stone", "stony",
	"stood", "stool", "stoop", "stop", "store", "stork", "storm", "story",
	"stout", "stove", "stow", "strap", "straw", "stray", "stream", "street",
	"stress", "stretch", "strict", "stride", "strife", "strike", "string", "strip",
	"stripe", "strive", "strobe", "stroke", "stroll", "strong", "strut", "stub",
	"stuck", "stud", "study", "stuff", "stump", "stung", "stunk", "stunt",
	"style", "suave", "sub", "such", "suck", "sudden", "suds", "sugar",
	"suit", "suite", "sulk", "sum", "summer", "summit", "sun", "sung",
	"sunk", "sunny", "super", "surf", "surge", "surly", "survey", "sushi",
	"swab", "swam", "swamp", "swan", "swap", "swarm", "sway", "swear",
	"sweat", "sweep", "sweet", "swell", "swept", "swift", "swim", "swine",
	"swing", "swipe", "swirl", "swiss", "switch", "sword", "swore", "sworn",
	"swung", "syrup", "tab", "table", "taboo", "tack", "tacky", "taco",
	"tact", "tag", "tail", "take", "taken", "tale", "talent", "talk",
	"tall", "tame", "tan", "tank", "tape", "tar", "tarp", "task",
	"taste", "tasty", "tattle", "taunt", "tax", "taxi", "teach", "teal",
	"team", "tear", "tease", "tech", "teddy", "teen", "teeth", "tell",
	"temp", "tempo", "tend", "tent", "tenth", "term", "test", "text",
	"than", "thank", "that", "thaw", "theft", "theme", "then", "there",
	"these", "thick", "thief", "thigh", "thin", "thing", "think", "third",
	"thirst", "this", "thorn", "those", "though", "thought", "thread", "threat",
	"three", "threw", "thrift", "thrill", "thrive", "throat", "throne", "throb",
	"throw", "thrown", "thud", "thug", "thumb", "thump", "thus", "tick",
	"ticket", "tide", "tidy", "tie", "tiger", "tight", "tile", "tilt",
	"time", "timid", "tin", "tiny", "tip", "tire", "tired", "tissue",
	"title", "toast", "today", "toe", "toffee", "tofu", "toga", "token",
	"told", "toll", "tomb", "ton", "tone", "tonic", "tons", "took",
	"tool", "toot", "tooth", "top", "topic", "torch", "torn", "toss",
	"total", "touch", "tough", "tour", "towel", "tower", "town", "toxic",
	"trace", "track", "tract", "trade", "trail", "train", "trait", "trap",
	"trash", "travel", "tray", "treat", "tree", "trek", "trend", "trial",
	"tribe", "trick", "tried", "trim", "trio", "trip", "trite", "troll",
	"troop", "trophy", "trot", "trouble", "trout", "truce", "truck", "true",
	"truly", "trump", "trunk", "trust", "truth", "try", "tub", "tuba",
	"tube", "tuck", "tuft", "tug", "tulip", "tumble", "tummy", "tumor",
	"tuna", "tune", "tunnel", "turbo", "turf", "turn", "tutor", "tux",
	"tweak", "tweed", "tweet", "twelve", "twenty", "twice", "twig", "twin",
	"twirl", "twist", "two", "tycoon", "type", "udder", "ugly", "ultra",
	"umpire", "uncle", "under", "undo", "unfit", "unfold", "unhappy", "unicorn",
	"unique", "unit", "unite", "unity", "unknown", "unlock", "until", "unusual",
	"unveil", "update", "upon", "upper", "upset", "urban", "urge", "urgent",
	"usage", "use", "used", "useful", "usher", "usual", "utter", "vacant",
	"vacuum", "vague", "vain", "valid", "valley", "valve", "van", "vanish",
	"vapor", "vary", "vase", "vast", "vault", "vegan", "vein", "velvet",
	"vendor", "vent", "venue", "verb", "verify", "verse", "very", "vessel",
	"vest", "vet", "veto", "via", "vibe", "vice", "video", "view",
	"vigor", "vile", "villa", "vine", "vinyl", "viola", "violet", "viper",
	"viral", "virtue", "virus", "visa", "visit", "visor", "vista", "vital",
	"vivid", "vocal", "vodka", "vogue", "voice", "void", "volt", "volume",
	"vomit", "vote", "voter", "vouch", "vow", "vowel", "voyage", "wad",
	"wade", "wager", "wagon", "waist", "wait", "wake", "walk", "walker",
	"wall", "wallet", "wander", "want", "war", "ward", "warm", "warn",
	"warp", "wart", "wary", "wash", "wasp", "waste", "watch", "water",
	"watery", "wave", "wavy", "wax", "way", "weak", "wealth", "weapon",
	"wear", "weary", "weasel", "weather", "weave", "web", "wed", "wedge",
	"weed", "week", "weep", "weigh", "weird", "welcome", "weld", "well",
	"west", "wet", "whale", "wharf", "wheat", "wheel", "when", "where",
	"which", "whiff", "while", "whim", "whine", "whip", "whisk", "whisper",
	"white", "who", "whole", "whom", "why", "wick", "wide", "widen",
	"widow", "width", "wife", "wifi", "wild", "will", "wilt", "wily",
	"win", "wince", "winch", "wind", "window", "wine", "wing", "wink",
	"winter", "wipe", "wire", "wisdom", "wise", "wish", "wit", "witch",
	"with", "wither", "within", "without", "witness", "witty", "woke", "woken",
	"wolf", "woman", "women", "won", "wonder", "wood", "wooden", "wool",
	"word", "work", "worker", "world", "worm", "worn", "worry", "worse",
	"worst", "worth", "worthy", "would", "wound", "woven", "wrap", "wrath",
	"wreath", "wreck", "wren", "wrench", "wrist", "write", "writer", "wrong",
	"wrote", "wrung", "yam", "yank", "yard", "yarn", "yawn", "year",
	"yeast", "yell", "yellow", "yelp", "yes", "yesterday", "yet", "yield",
	"yoga", "yolk", "you", "young", "your", "youth", "zebra", "zen",
	"zero", "zest", "zinc", "zip", "zombie", "zone", "zoo", "zoom",
}

// GeneratePairingCode generates a human-readable pairing code like "7-tiger-castle"
func GeneratePairingCode() (string, error) {
	// Generate random number 1-9 (not 0 to avoid confusion)
	numBig, err := rand.Int(rand.Reader, big.NewInt(9))
	if err != nil {
		return "", err
	}
	num := numBig.Int64() + 1

	// Pick 2 random words
	words := make([]string, 2)
	for i := 0; i < 2; i++ {
		idx, err := rand.Int(rand.Reader, big.NewInt(int64(len(wordlist))))
		if err != nil {
			return "", err
		}
		words[i] = wordlist[idx.Int64()]
	}

	return fmt.Sprintf("%d-%s-%s", num, words[0], words[1]), nil
}

// ParsePairingCode validates and normalizes a pairing code
func ParsePairingCode(code string) (string, error) {
	code = strings.ToLower(strings.TrimSpace(code))
	parts := strings.Split(code, "-")
	if len(parts) != 3 {
		return "", fmt.Errorf("invalid code format: expected NUMBER-WORD-WORD")
	}

	// Validate number
	var num int
	if _, err := fmt.Sscanf(parts[0], "%d", &num); err != nil || num < 1 || num > 9 {
		return "", fmt.Errorf("invalid code: first part must be 1-9")
	}

	// Validate words exist in wordlist
	for i := 1; i <= 2; i++ {
		found := false
		for _, w := range wordlist {
			if w == parts[i] {
				found = true
				break
			}
		}
		if !found {
			return "", fmt.Errorf("invalid code: unknown word '%s'", parts[i])
		}
	}

	return code, nil
}

// CodeToBytes converts a pairing code to bytes for SPAKE2 password
func CodeToBytes(code string) []byte {
	return []byte(code)
}
