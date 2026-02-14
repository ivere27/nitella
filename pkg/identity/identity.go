// Package identity handles cryptographic identity generation and management.
// It provides BIP-39 mnemonic-based Root CA generation for nitella CLI and nitellad.
package identity

import (
	"crypto/ed25519"
	"crypto/rand"
	"crypto/sha256"
	"crypto/sha512"
	"crypto/subtle"
	"crypto/x509"
	"crypto/x509/pkix"
	"encoding/hex"
	"encoding/pem"
	"errors"
	"fmt"
	"math/big"
	"os"
	"path/filepath"
	"strings"
	"time"

	nitellacrypto "github.com/ivere27/nitella/pkg/crypto"
	"golang.org/x/crypto/hkdf"
	"golang.org/x/crypto/pbkdf2"
)

// Emoji set for visual hash (256 emojis for 8-bit mapping)
var emojiSet = []string{
	"🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼",
	"🐨", "🐯", "🦁", "🐮", "🐷", "🐸", "🐵", "🐔",
	"🐧", "🐦", "🐤", "🦆", "🦅", "🦉", "🦇", "🐺",
	"🐗", "🐴", "🦄", "🐝", "🐛", "🦋", "🐌", "🐞",
	"🐜", "🦟", "🦗", "🕷️", "🦂", "🐢", "🐍", "🦎",
	"🦖", "🦕", "🐙", "🦑", "🦐", "🦞", "🦀", "🐡",
	"🐠", "🐟", "🐬", "🐳", "🐋", "🦈", "🐊", "🐅",
	"🐆", "🦓", "🦍", "🦧", "🐘", "🦛", "🦏", "🐪",
	"🐫", "🦒", "🦘", "🐃", "🐂", "🐄", "🐎", "🐖",
	"🐏", "🐑", "🦙", "🐐", "🦌", "🐕", "🐩", "🦮",
	"🐕‍🦺", "🐈", "🐓", "🦃", "🦚", "🦜", "🦢", "🦩",
	"🕊️", "🐇", "🦝", "🦨", "🦡", "🦫", "🦦", "🦥",
	"🐁", "🐀", "🐿️", "🦔", "🌵", "🎄", "🌲", "🌳",
	"🌴", "🌱", "🌿", "☘️", "🍀", "🎍", "🎋", "🍃",
	"🍂", "🍁", "🍄", "🌾", "💐", "🌷", "🌹", "🥀",
	"🌺", "🌸", "🌼", "🌻", "🌞", "🌝", "🌛", "🌜",
	"🌚", "🌕", "🌖", "🌗", "🌘", "🌑", "🌒", "🌓",
	"🌔", "🌙", "🌎", "🌍", "🌏", "🪐", "💫", "⭐",
	"🌟", "✨", "⚡", "☄️", "💥", "🔥", "🌪️", "🌈",
	"☀️", "🌤️", "⛅", "🌥️", "☁️", "🌦️", "🌧️", "⛈️",
	"🌩️", "🌨️", "❄️", "☃️", "⛄", "🌬️", "💨", "💧",
	"💦", "☔", "☂️", "🌊", "🍏", "🍎", "🍐", "🍊",
	"🍋", "🍌", "🍉", "🍇", "🍓", "🫐", "🍈", "🍒",
	"🍑", "🥭", "🍍", "🥥", "🥝", "🍅", "🍆", "🥑",
	"🥦", "🥬", "🥒", "🌶️", "🫑", "🌽", "🥕", "🫒",
	"🧄", "🧅", "🥔", "🍠", "🥐", "🥯", "🍞", "🥖",
	"🥨", "🧀", "🥚", "🍳", "🧈", "🥞", "🧇", "🥓",
	"🥩", "🍗", "🍖", "🦴", "🌭", "🍔", "🍟", "🍕",
	"🫓", "🥪", "🥙", "🧆", "🌮", "🌯", "🫔", "🥗",
	"🥘", "🫕", "🥫", "🍝", "🍜", "🍲", "🍛", "🍣",
	"🍱", "🥟", "🦪", "🍤", "🍙", "🍚", "🍘", "🍥",
	"🥠", "🥮", "🍢", "🍡", "🍧", "🍨", "🍦", "🥧",
}

// BIP-39 English wordlist (2048 words)
var bip39Words = []string{
	"abandon", "ability", "able", "about", "above", "absent", "absorb", "abstract",
	"absurd", "abuse", "access", "accident", "account", "accuse", "achieve", "acid",
	"acoustic", "acquire", "across", "act", "action", "actor", "actress", "actual",
	"adapt", "add", "addict", "address", "adjust", "admit", "adult", "advance",
	"advice", "aerobic", "affair", "afford", "afraid", "again", "age", "agent",
	"agree", "ahead", "aim", "air", "airport", "aisle", "alarm", "album",
	"alcohol", "alert", "alien", "all", "alley", "allow", "almost", "alone",
	"alpha", "already", "also", "alter", "always", "amateur", "amazing", "among",
	"amount", "amused", "analyst", "anchor", "ancient", "anger", "angle", "angry",
	"animal", "ankle", "announce", "annual", "another", "answer", "antenna", "antique",
	"anxiety", "any", "apart", "apology", "appear", "apple", "approve", "april",
	"arch", "arctic", "area", "arena", "argue", "arm", "armed", "armor",
	"army", "around", "arrange", "arrest", "arrive", "arrow", "art", "artefact",
	"artist", "artwork", "ask", "aspect", "assault", "asset", "assist", "assume",
	"asthma", "athlete", "atom", "attack", "attend", "attitude", "attract", "auction",
	"audit", "august", "aunt", "author", "auto", "autumn", "average", "avocado",
	"avoid", "awake", "aware", "away", "awesome", "awful", "awkward", "axis",
	"baby", "bachelor", "bacon", "badge", "bag", "balance", "balcony", "ball",
	"bamboo", "banana", "banner", "bar", "barely", "bargain", "barrel", "base",
	"basic", "basket", "battle", "beach", "bean", "beauty", "because", "become",
	"beef", "before", "begin", "behave", "behind", "believe", "below", "belt",
	"bench", "benefit", "best", "betray", "better", "between", "beyond", "bicycle",
	"bid", "bike", "bind", "biology", "bird", "birth", "bitter", "black",
	"blade", "blame", "blanket", "blast", "bleak", "bless", "blind", "blood",
	"blossom", "blouse", "blue", "blur", "blush", "board", "boat", "body",
	"boil", "bomb", "bone", "bonus", "book", "boost", "border", "boring",
	"borrow", "boss", "bottom", "bounce", "box", "boy", "bracket", "brain",
	"brand", "brass", "brave", "bread", "breeze", "brick", "bridge", "brief",
	"bright", "bring", "brisk", "broccoli", "broken", "bronze", "broom", "brother",
	"brown", "brush", "bubble", "buddy", "budget", "buffalo", "build", "bulb",
	"bulk", "bullet", "bundle", "bunker", "burden", "burger", "burst", "bus",
	"business", "busy", "butter", "buyer", "buzz", "cabbage", "cabin", "cable",
	"cactus", "cage", "cake", "call", "calm", "camera", "camp", "can",
	"canal", "cancel", "candy", "cannon", "canoe", "canvas", "canyon", "capable",
	"capital", "captain", "car", "carbon", "card", "cargo", "carpet", "carry",
	"cart", "case", "cash", "casino", "castle", "casual", "cat", "catalog",
	"catch", "category", "cattle", "caught", "cause", "caution", "cave", "ceiling",
	"celery", "cement", "census", "century", "cereal", "certain", "chair", "chalk",
	"champion", "change", "chaos", "chapter", "charge", "chase", "chat", "cheap",
	"check", "cheese", "chef", "cherry", "chest", "chicken", "chief", "child",
	"chimney", "choice", "choose", "chronic", "chuckle", "chunk", "churn", "cigar",
	"cinnamon", "circle", "citizen", "city", "civil", "claim", "clap", "clarify",
	"claw", "clay", "clean", "clerk", "clever", "click", "client", "cliff",
	"climb", "clinic", "clip", "clock", "clog", "close", "cloth", "cloud",
	"clown", "club", "clump", "cluster", "clutch", "coach", "coast", "coconut",
	"code", "coffee", "coil", "coin", "collect", "color", "column", "combine",
	"come", "comfort", "comic", "common", "company", "concert", "conduct", "confirm",
	"congress", "connect", "consider", "control", "convince", "cook", "cool", "copper",
	"copy", "coral", "core", "corn", "correct", "cost", "cotton", "couch",
	"country", "couple", "course", "cousin", "cover", "coyote", "crack", "cradle",
	"craft", "cram", "crane", "crash", "crater", "crawl", "crazy", "cream",
	"credit", "creek", "crew", "cricket", "crime", "crisp", "critic", "crop",
	"cross", "crouch", "crowd", "crucial", "cruel", "cruise", "crumble", "crunch",
	"crush", "cry", "crystal", "cube", "culture", "cup", "cupboard", "curious",
	"current", "curtain", "curve", "cushion", "custom", "cute", "cycle", "dad",
	"damage", "damp", "dance", "danger", "daring", "dash", "daughter", "dawn",
	"day", "deal", "debate", "debris", "decade", "december", "decide", "decline",
	"decorate", "decrease", "deer", "defense", "define", "defy", "degree", "delay",
	"deliver", "demand", "demise", "denial", "dentist", "deny", "depart", "depend",
	"deposit", "depth", "deputy", "derive", "describe", "desert", "design", "desk",
	"despair", "destroy", "detail", "detect", "develop", "device", "devote", "diagram",
	"dial", "diamond", "diary", "dice", "diesel", "diet", "differ", "digital",
	"dignity", "dilemma", "dinner", "dinosaur", "direct", "dirt", "disagree", "discover",
	"disease", "dish", "dismiss", "disorder", "display", "distance", "divert", "divide",
	"divorce", "dizzy", "doctor", "document", "dog", "doll", "dolphin", "domain",
	"donate", "donkey", "donor", "door", "dose", "double", "dove", "draft",
	"dragon", "drama", "drastic", "draw", "dream", "dress", "drift", "drill",
	"drink", "drip", "drive", "drop", "drum", "dry", "duck", "dumb",
	"dune", "during", "dust", "dutch", "duty", "dwarf", "dynamic", "eager",
	"eagle", "early", "earn", "earth", "easily", "east", "easy", "echo",
	"ecology", "economy", "edge", "edit", "educate", "effort", "egg", "eight",
	"either", "elbow", "elder", "electric", "elegant", "element", "elephant", "elevator",
	"elite", "else", "embark", "embody", "embrace", "emerge", "emotion", "employ",
	"empower", "empty", "enable", "enact", "end", "endless", "endorse", "enemy",
	"energy", "enforce", "engage", "engine", "enhance", "enjoy", "enlist", "enough",
	"enrich", "enroll", "ensure", "enter", "entire", "entry", "envelope", "episode",
	"equal", "equip", "era", "erase", "erode", "erosion", "error", "erupt",
	"escape", "essay", "essence", "estate", "eternal", "ethics", "evidence", "evil",
	"evoke", "evolve", "exact", "example", "excess", "exchange", "excite", "exclude",
	"excuse", "execute", "exercise", "exhaust", "exhibit", "exile", "exist", "exit",
	"exotic", "expand", "expect", "expire", "explain", "expose", "express", "extend",
	"extra", "eye", "eyebrow", "fabric", "face", "faculty", "fade", "faint",
	"faith", "fall", "false", "fame", "family", "famous", "fan", "fancy",
	"fantasy", "farm", "fashion", "fat", "fatal", "father", "fatigue", "fault",
	"favorite", "feature", "february", "federal", "fee", "feed", "feel", "female",
	"fence", "festival", "fetch", "fever", "few", "fiber", "fiction", "field",
	"figure", "file", "film", "filter", "final", "find", "fine", "finger",
	"finish", "fire", "firm", "first", "fiscal", "fish", "fit", "fitness",
	"fix", "flag", "flame", "flash", "flat", "flavor", "flee", "flight",
	"flip", "float", "flock", "floor", "flower", "fluid", "flush", "fly",
	"foam", "focus", "fog", "foil", "fold", "follow", "food", "foot",
	"force", "forest", "forget", "fork", "fortune", "forum", "forward", "fossil",
	"foster", "found", "fox", "fragile", "frame", "frequent", "fresh", "friend",
	"fringe", "frog", "front", "frost", "frown", "frozen", "fruit", "fuel",
	"fun", "funny", "furnace", "fury", "future", "gadget", "gain", "galaxy",
	"gallery", "game", "gap", "garage", "garbage", "garden", "garlic", "garment",
	"gas", "gasp", "gate", "gather", "gauge", "gaze", "general", "genius",
	"genre", "gentle", "genuine", "gesture", "ghost", "giant", "gift", "giggle",
	"ginger", "giraffe", "girl", "give", "glad", "glance", "glare", "glass",
	"glide", "glimpse", "globe", "gloom", "glory", "glove", "glow", "glue",
	"goat", "goddess", "gold", "good", "goose", "gorilla", "gospel", "gossip",
	"govern", "gown", "grab", "grace", "grain", "grant", "grape", "grass",
	"gravity", "great", "green", "grid", "grief", "grit", "grocery", "group",
	"grow", "grunt", "guard", "guess", "guide", "guilt", "guitar", "gun",
	"gym", "habit", "hair", "half", "hammer", "hamster", "hand", "happy",
	"harbor", "hard", "harsh", "harvest", "hat", "have", "hawk", "hazard",
	"head", "health", "heart", "heavy", "hedgehog", "height", "hello", "helmet",
	"help", "hen", "hero", "hidden", "high", "hill", "hint", "hip",
	"hire", "history", "hobby", "hockey", "hold", "hole", "holiday", "hollow",
	"home", "honey", "hood", "hope", "horn", "horror", "horse", "hospital",
	"host", "hotel", "hour", "hover", "hub", "huge", "human", "humble",
	"humor", "hundred", "hungry", "hunt", "hurdle", "hurry", "hurt", "husband",
	"hybrid", "ice", "icon", "idea", "identify", "idle", "ignore", "ill",
	"illegal", "illness", "image", "imitate", "immense", "immune", "impact", "impose",
	"improve", "impulse", "inch", "include", "income", "increase", "index", "indicate",
	"indoor", "industry", "infant", "inflict", "inform", "inhale", "inherit", "initial",
	"inject", "injury", "inmate", "inner", "innocent", "input", "inquiry", "insane",
	"insect", "inside", "inspire", "install", "intact", "interest", "into", "invest",
	"invite", "involve", "iron", "island", "isolate", "issue", "item", "ivory",
	"jacket", "jaguar", "jar", "jazz", "jealous", "jeans", "jelly", "jewel",
	"job", "join", "joke", "journey", "joy", "judge", "juice", "jump",
	"jungle", "junior", "junk", "just", "kangaroo", "keen", "keep", "ketchup",
	"key", "kick", "kid", "kidney", "kind", "kingdom", "kiss", "kit",
	"kitchen", "kite", "kitten", "kiwi", "knee", "knife", "knock", "know",
	"lab", "label", "labor", "ladder", "lady", "lake", "lamp", "language",
	"laptop", "large", "later", "latin", "laugh", "laundry", "lava", "law",
	"lawn", "lawsuit", "layer", "lazy", "leader", "leaf", "learn", "leave",
	"lecture", "left", "leg", "legal", "legend", "leisure", "lemon", "lend",
	"length", "lens", "leopard", "lesson", "letter", "level", "liar", "liberty",
	"library", "license", "life", "lift", "light", "like", "limb", "limit",
	"link", "lion", "liquid", "list", "little", "live", "lizard", "load",
	"loan", "lobster", "local", "lock", "logic", "lonely", "long", "loop",
	"lottery", "loud", "lounge", "love", "loyal", "lucky", "luggage", "lumber",
	"lunar", "lunch", "luxury", "lyrics", "machine", "mad", "magic", "magnet",
	"maid", "mail", "main", "major", "make", "mammal", "man", "manage",
	"mandate", "mango", "mansion", "manual", "maple", "marble", "march", "margin",
	"marine", "market", "marriage", "mask", "mass", "master", "match", "material",
	"math", "matrix", "matter", "maximum", "maze", "meadow", "mean", "measure",
	"meat", "mechanic", "medal", "media", "melody", "melt", "member", "memory",
	"mention", "menu", "mercy", "merge", "merit", "merry", "mesh", "message",
	"metal", "method", "middle", "midnight", "milk", "million", "mimic", "mind",
	"minimum", "minor", "minute", "miracle", "mirror", "misery", "miss", "mistake",
	"mix", "mixed", "mixture", "mobile", "model", "modify", "mom", "moment",
	"monitor", "monkey", "monster", "month", "moon", "moral", "more", "morning",
	"mosquito", "mother", "motion", "motor", "mountain", "mouse", "move", "movie",
	"much", "muffin", "mule", "multiply", "muscle", "museum", "mushroom", "music",
	"must", "mutual", "myself", "mystery", "myth", "naive", "name", "napkin",
	"narrow", "nasty", "nation", "nature", "near", "neck", "need", "negative",
	"neglect", "neither", "nephew", "nerve", "nest", "net", "network", "neutral",
	"never", "news", "next", "nice", "night", "noble", "noise", "nominee",
	"noodle", "normal", "north", "nose", "notable", "note", "nothing", "notice",
	"novel", "now", "nuclear", "number", "nurse", "nut", "oak", "obey",
	"object", "oblige", "obscure", "observe", "obtain", "obvious", "occur", "ocean",
	"october", "odor", "off", "offer", "office", "often", "oil", "okay",
	"old", "olive", "olympic", "omit", "once", "one", "onion", "online",
	"only", "open", "opera", "opinion", "oppose", "option", "orange", "orbit",
	"orchard", "order", "ordinary", "organ", "orient", "original", "orphan", "ostrich",
	"other", "outdoor", "outer", "output", "outside", "oval", "oven", "over",
	"own", "owner", "oxygen", "oyster", "ozone", "pact", "paddle", "page",
	"pair", "palace", "palm", "panda", "panel", "panic", "panther", "paper",
	"parade", "parent", "park", "parrot", "party", "pass", "patch", "path",
	"patient", "patrol", "pattern", "pause", "pave", "payment", "peace", "peanut",
	"pear", "peasant", "pelican", "pen", "penalty", "pencil", "people", "pepper",
	"perfect", "permit", "person", "pet", "phone", "photo", "phrase", "physical",
	"piano", "picnic", "picture", "piece", "pig", "pigeon", "pill", "pilot",
	"pink", "pioneer", "pipe", "pistol", "pitch", "pizza", "place", "planet",
	"plastic", "plate", "play", "please", "pledge", "pluck", "plug", "plunge",
	"poem", "poet", "point", "polar", "pole", "police", "pond", "pony",
	"pool", "popular", "portion", "position", "possible", "post", "potato", "pottery",
	"poverty", "powder", "power", "practice", "praise", "predict", "prefer", "prepare",
	"present", "pretty", "prevent", "price", "pride", "primary", "print", "priority",
	"prison", "private", "prize", "problem", "process", "produce", "profit", "program",
	"project", "promote", "proof", "property", "prosper", "protect", "proud", "provide",
	"public", "pudding", "pull", "pulp", "pulse", "pumpkin", "punch", "pupil",
	"puppy", "purchase", "purity", "purpose", "purse", "push", "put", "puzzle",
	"pyramid", "quality", "quantum", "quarter", "question", "quick", "quit", "quiz",
	"quote", "rabbit", "raccoon", "race", "rack", "radar", "radio", "rail",
	"rain", "raise", "rally", "ramp", "ranch", "random", "range", "rapid",
	"rare", "rate", "rather", "raven", "raw", "razor", "ready", "real",
	"reason", "rebel", "rebuild", "recall", "receive", "recipe", "record", "recycle",
	"reduce", "reflect", "reform", "refuse", "region", "regret", "regular", "reject",
	"relax", "release", "relief", "rely", "remain", "remember", "remind", "remove",
	"render", "renew", "rent", "reopen", "repair", "repeat", "replace", "report",
	"require", "rescue", "resemble", "resist", "resource", "response", "result", "retire",
	"retreat", "return", "reunion", "reveal", "review", "reward", "rhythm", "rib",
	"ribbon", "rice", "rich", "ride", "ridge", "rifle", "right", "rigid",
	"ring", "riot", "ripple", "risk", "ritual", "rival", "river", "road",
	"roast", "robot", "robust", "rocket", "romance", "roof", "rookie", "room",
	"rose", "rotate", "rough", "round", "route", "royal", "rubber", "rude",
	"rug", "rule", "run", "runway", "rural", "sad", "saddle", "sadness",
	"safe", "sail", "salad", "salmon", "salon", "salt", "salute", "same",
	"sample", "sand", "satisfy", "satoshi", "sauce", "sausage", "save", "say",
	"scale", "scan", "scare", "scatter", "scene", "scheme", "school", "science",
	"scissors", "scorpion", "scout", "scrap", "screen", "script", "scrub", "sea",
	"search", "season", "seat", "second", "secret", "section", "security", "seed",
	"seek", "segment", "select", "sell", "seminar", "senior", "sense", "sentence",
	"series", "service", "session", "settle", "setup", "seven", "shadow", "shaft",
	"shallow", "share", "shed", "shell", "sheriff", "shield", "shift", "shine",
	"ship", "shiver", "shock", "shoe", "shoot", "shop", "short", "shoulder",
	"shove", "shrimp", "shrug", "shuffle", "shy", "sibling", "sick", "side",
	"siege", "sight", "sign", "silent", "silk", "silly", "silver", "similar",
	"simple", "since", "sing", "siren", "sister", "situate", "six", "size",
	"skate", "sketch", "ski", "skill", "skin", "skirt", "skull", "slab",
	"slam", "sleep", "slender", "slice", "slide", "slight", "slim", "slogan",
	"slot", "slow", "slush", "small", "smart", "smile", "smoke", "smooth",
	"snack", "snake", "snap", "sniff", "snow", "soap", "soccer", "social",
	"sock", "soda", "soft", "solar", "soldier", "solid", "solution", "solve",
	"someone", "song", "soon", "sorry", "sort", "soul", "sound", "soup",
	"source", "south", "space", "spare", "spatial", "spawn", "speak", "special",
	"speed", "spell", "spend", "sphere", "spice", "spider", "spike", "spin",
	"spirit", "split", "spoil", "sponsor", "spoon", "sport", "spot", "spray",
	"spread", "spring", "spy", "square", "squeeze", "squirrel", "stable", "stadium",
	"staff", "stage", "stairs", "stamp", "stand", "start", "state", "stay",
	"steak", "steel", "stem", "step", "stereo", "stick", "still", "sting",
	"stock", "stomach", "stone", "stool", "story", "stove", "strategy", "street",
	"strike", "strong", "struggle", "student", "stuff", "stumble", "style", "subject",
	"submit", "subway", "success", "such", "sudden", "suffer", "sugar", "suggest",
	"suit", "summer", "sun", "sunny", "sunset", "super", "supply", "supreme",
	"sure", "surface", "surge", "surprise", "surround", "survey", "suspect", "sustain",
	"swallow", "swamp", "swap", "swarm", "swear", "sweet", "swift", "swim",
	"swing", "switch", "sword", "symbol", "symptom", "syrup", "system", "table",
	"tackle", "tag", "tail", "talent", "talk", "tank", "tape", "target",
	"task", "taste", "tattoo", "taxi", "teach", "team", "tell", "ten",
	"tenant", "tennis", "tent", "term", "test", "text", "thank", "that",
	"theme", "then", "theory", "there", "they", "thing", "this", "thought",
	"three", "thrive", "throw", "thumb", "thunder", "ticket", "tide", "tiger",
	"tilt", "timber", "time", "tiny", "tip", "tired", "tissue", "title",
	"toast", "tobacco", "today", "toddler", "toe", "together", "toilet", "token",
	"tomato", "tomorrow", "tone", "tongue", "tonight", "tool", "tooth", "top",
	"topic", "topple", "torch", "tornado", "tortoise", "toss", "total", "tourist",
	"toward", "tower", "town", "toy", "track", "trade", "traffic", "tragic",
	"train", "transfer", "trap", "trash", "travel", "tray", "treat", "tree",
	"trend", "trial", "tribe", "trick", "trigger", "trim", "trip", "trophy",
	"trouble", "truck", "true", "truly", "trumpet", "trust", "truth", "try",
	"tube", "tuition", "tumble", "tuna", "tunnel", "turkey", "turn", "turtle",
	"twelve", "twenty", "twice", "twin", "twist", "two", "type", "typical",
	"ugly", "umbrella", "unable", "unaware", "uncle", "uncover", "under", "undo",
	"unfair", "unfold", "unhappy", "uniform", "unique", "unit", "universe", "unknown",
	"unlock", "until", "unusual", "unveil", "update", "upgrade", "uphold", "upon",
	"upper", "upset", "urban", "urge", "usage", "use", "used", "useful",
	"useless", "usual", "utility", "vacant", "vacuum", "vague", "valid", "valley",
	"valve", "van", "vanish", "vapor", "various", "vast", "vault", "vehicle",
	"velvet", "vendor", "venture", "venue", "verb", "verify", "version", "very",
	"vessel", "veteran", "viable", "vibrant", "vicious", "victory", "video", "view",
	"village", "vintage", "violin", "virtual", "virus", "visa", "visit", "visual",
	"vital", "vivid", "vocal", "voice", "void", "volcano", "volume", "vote",
	"voyage", "wage", "wagon", "wait", "walk", "wall", "walnut", "want",
	"warfare", "warm", "warrior", "wash", "wasp", "waste", "water", "wave",
	"way", "wealth", "weapon", "wear", "weasel", "weather", "web", "wedding",
	"weekend", "weird", "welcome", "west", "wet", "whale", "what", "wheat",
	"wheel", "when", "where", "whip", "whisper", "wide", "width", "wife",
	"wild", "will", "win", "window", "wine", "wing", "wink", "winner",
	"winter", "wire", "wisdom", "wise", "wish", "witness", "wolf", "woman",
	"wonder", "wood", "wool", "word", "work", "world", "worry", "worth",
	"wrap", "wreck", "wrestle", "wrist", "write", "wrong", "yard", "year",
	"yellow", "you", "young", "youth", "zebra", "zero", "zone", "zoo",
}

// Identity represents a cryptographic identity with Root CA
type Identity struct {
	Mnemonic    string             // BIP-39 mnemonic phrase (only set during creation, not persisted)
	RootKey     ed25519.PrivateKey // Root CA private key
	RootCert    *x509.Certificate  // Self-signed Root CA
	RootCertPEM []byte
	RootKeyPEM  []byte
	EmojiHash   string // Visual verification hash
	Fingerprint string // SHA256 fingerprint of public key
}

// Config holds identity configuration
type Config struct {
	DataDir     string
	CommonName  string // e.g., "nitella-cli" or "nitellad"
	ValidYears  int
	ForceCreate bool
	Passphrase  string                  // Passphrase for encrypting private key (empty = no encryption)
	KDFParams   nitellacrypto.KDFParams // KDF parameters for passphrase encryption (zero value = default)
}

// DefaultConfig returns default identity configuration
func DefaultConfig(dataDir, commonName string) *Config {
	return &Config{
		DataDir:    dataDir,
		CommonName: commonName,
		ValidYears: 10,
	}
}

// LoadOrCreate loads existing identity or creates a new one
func LoadOrCreate(cfg *Config) (*Identity, bool, error) {
	if cfg.DataDir == "" {
		homeDir, err := os.UserHomeDir()
		if err != nil {
			return nil, false, err
		}
		cfg.DataDir = filepath.Join(homeDir, ".nitella")
	}

	// Ensure directory exists
	if err := os.MkdirAll(cfg.DataDir, 0700); err != nil {
		return nil, false, fmt.Errorf("failed to create data directory: %w", err)
	}

	certPath := filepath.Join(cfg.DataDir, "root_ca.crt")
	keyPath := filepath.Join(cfg.DataDir, "root_ca.key")

	// Try to load existing identity
	if !cfg.ForceCreate {
		if _, err := os.Stat(keyPath); err == nil {
			identity, err := LoadWithPassphrase(cfg.DataDir, cfg.Passphrase)
			if err == nil {
				return identity, false, nil
			}
			// Return error if passphrase is wrong (don't fall through to create)
			if err.Error() == "passphrase required for encrypted key" ||
				strings.Contains(err.Error(), "decryption failed") {
				return nil, false, err
			}
		}
	}

	// Create new identity
	identity, err := Create(cfg)
	if err != nil {
		return nil, false, err
	}

	// Save certificate (unencrypted)
	if err := os.WriteFile(certPath, identity.RootCertPEM, 0644); err != nil {
		return nil, false, fmt.Errorf("failed to save root cert: %w", err)
	}

	// Save key (encrypted if passphrase provided)
	kdfParams := cfg.KDFParams
	if kdfParams.Time == 0 {
		kdfParams = nitellacrypto.KDFDefault // Use default if not specified
	}
	keyPEM, err := nitellacrypto.EncryptPrivateKeyToPEMWithParams(identity.RootKey, cfg.Passphrase, kdfParams)
	if err != nil {
		return nil, false, fmt.Errorf("failed to encrypt key: %w", err)
	}
	if err := os.WriteFile(keyPath, keyPEM, 0600); err != nil {
		return nil, false, fmt.Errorf("failed to save root key: %w", err)
	}

	return identity, true, nil
}

// Load loads an existing identity from disk (without passphrase - for unencrypted keys)
func Load(dataDir string) (*Identity, error) {
	return LoadWithPassphrase(dataDir, "")
}

// LoadWithPassphrase loads an existing identity from disk, decrypting if necessary
func LoadWithPassphrase(dataDir, passphrase string) (*Identity, error) {
	certPath := filepath.Join(dataDir, "root_ca.crt")
	keyPath := filepath.Join(dataDir, "root_ca.key")

	// Read certificate
	certPEM, err := os.ReadFile(certPath)
	if err != nil {
		return nil, fmt.Errorf("failed to read certificate: %w", err)
	}

	// Read key
	keyPEM, err := os.ReadFile(keyPath)
	if err != nil {
		return nil, fmt.Errorf("failed to read key: %w", err)
	}

	// Parse certificate
	block, _ := pem.Decode(certPEM)
	if block == nil {
		return nil, errors.New("failed to decode certificate PEM")
	}
	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return nil, fmt.Errorf("failed to parse certificate: %w", err)
	}

	// Parse key (handles both encrypted and unencrypted)
	edKey, err := nitellacrypto.DecryptPrivateKeyFromPEM(keyPEM, passphrase)
	if err != nil {
		return nil, err
	}

	identity := &Identity{
		RootKey:     edKey,
		RootCert:    cert,
		RootCertPEM: certPEM,
		RootKeyPEM:  keyPEM,
	}

	// Generate emoji hash and fingerprint
	identity.EmojiHash = GenerateEmojiHash(edKey.Public().(ed25519.PublicKey))
	identity.Fingerprint = GenerateFingerprint(edKey.Public().(ed25519.PublicKey))

	return identity, nil
}

// ImportFromPEM imports an identity from certificate and private key PEM content
func ImportFromPEM(certPEM, keyPEM []byte, keyPassphrase string) (*Identity, error) {
	// Parse certificate
	block, _ := pem.Decode(certPEM)
	if block == nil {
		return nil, errors.New("failed to decode certificate PEM")
	}
	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return nil, fmt.Errorf("failed to parse certificate: %w", err)
	}

	// Verify it's a CA certificate
	if !cert.IsCA {
		return nil, errors.New("certificate is not a CA certificate")
	}

	// Parse key (handles both encrypted and unencrypted)
	edKey, err := nitellacrypto.DecryptPrivateKeyFromPEM(keyPEM, keyPassphrase)
	if err != nil {
		return nil, fmt.Errorf("failed to parse private key: %w", err)
	}

	// Verify key matches certificate
	certPubKey, ok := cert.PublicKey.(ed25519.PublicKey)
	if !ok {
		return nil, errors.New("certificate does not contain Ed25519 public key")
	}

	keyPubKey := edKey.Public().(ed25519.PublicKey)
	if !pubKeysEqual(certPubKey, keyPubKey) {
		return nil, errors.New("private key does not match certificate public key")
	}

	identity := &Identity{
		RootKey:     edKey,
		RootCert:    cert,
		RootCertPEM: certPEM,
		RootKeyPEM:  keyPEM,
	}

	// Generate emoji hash and fingerprint
	identity.EmojiHash = GenerateEmojiHash(keyPubKey)
	identity.Fingerprint = GenerateFingerprint(keyPubKey)

	return identity, nil
}

// pubKeysEqual compares two Ed25519 public keys using constant-time comparison.
func pubKeysEqual(a, b ed25519.PublicKey) bool {
	return subtle.ConstantTimeCompare(a, b) == 1
}

// IsKeyEncrypted checks if the key file in the data directory is encrypted
func IsKeyEncrypted(dataDir string) (bool, error) {
	keyPath := filepath.Join(dataDir, "root_ca.key")
	keyPEM, err := os.ReadFile(keyPath)
	if err != nil {
		return false, err
	}

	block, _ := pem.Decode(keyPEM)
	if block == nil {
		return false, errors.New("failed to decode key PEM")
	}

	return block.Type == "ENCRYPTED PRIVATE KEY", nil
}

// KeyExists checks if a key file exists in the data directory
func KeyExists(dataDir string) bool {
	keyPath := filepath.Join(dataDir, "root_ca.key")
	_, err := os.Stat(keyPath)
	return err == nil
}

// Create creates a new identity with a random mnemonic
func Create(cfg *Config) (*Identity, error) {
	// Generate random entropy (128 bits for 12-word mnemonic)
	entropy := make([]byte, 16)
	if _, err := rand.Read(entropy); err != nil {
		return nil, fmt.Errorf("failed to generate entropy: %w", err)
	}

	// Generate mnemonic
	mnemonic := entropyToMnemonic(entropy)

	return CreateFromMnemonic(mnemonic, cfg)
}

// CreateFromMnemonic creates an identity from an existing mnemonic
func CreateFromMnemonic(mnemonic string, cfg *Config) (*Identity, error) {
	// Derive seed from mnemonic using HKDF
	seed := mnemonicToSeed(mnemonic)

	// Derive Ed25519 key from seed
	hkdfReader := hkdf.New(sha256.New, seed, []byte("nitella-root-ca"), []byte("ed25519-key"))
	keyMaterial := make([]byte, ed25519.SeedSize)
	if _, err := hkdfReader.Read(keyMaterial); err != nil {
		return nil, fmt.Errorf("failed to derive key: %w", err)
	}
	privateKey := ed25519.NewKeyFromSeed(keyMaterial)

	// Generate self-signed Root CA certificate
	now := time.Now()
	serialNumber, err := rand.Int(rand.Reader, new(big.Int).Lsh(big.NewInt(1), 128))
	if err != nil {
		panic("crypto/rand failed: " + err.Error())
	}

	template := &x509.Certificate{
		SerialNumber: serialNumber,
		Subject: pkix.Name{
			CommonName:   cfg.CommonName + " Root CA",
			Organization: []string{"Nitella"},
		},
		NotBefore:             now,
		NotAfter:              now.AddDate(cfg.ValidYears, 0, 0),
		KeyUsage:              x509.KeyUsageCertSign | x509.KeyUsageCRLSign | x509.KeyUsageDigitalSignature,
		ExtKeyUsage:           []x509.ExtKeyUsage{x509.ExtKeyUsageClientAuth, x509.ExtKeyUsageServerAuth},
		BasicConstraintsValid: true,
		IsCA:                  true,
		MaxPathLen:            1,
	}

	certDER, err := x509.CreateCertificate(rand.Reader, template, template, privateKey.Public(), privateKey)
	if err != nil {
		return nil, fmt.Errorf("failed to create certificate: %w", err)
	}

	cert, _ := x509.ParseCertificate(certDER)
	certPEM := pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: certDER})

	pkcs8Key, _ := x509.MarshalPKCS8PrivateKey(privateKey)
	keyPEM := pem.EncodeToMemory(&pem.Block{Type: "PRIVATE KEY", Bytes: pkcs8Key})

	identity := &Identity{
		Mnemonic:    mnemonic,
		RootKey:     privateKey,
		RootCert:    cert,
		RootCertPEM: certPEM,
		RootKeyPEM:  keyPEM,
	}

	// Generate emoji hash and fingerprint
	identity.EmojiHash = GenerateEmojiHash(privateKey.Public().(ed25519.PublicKey))
	identity.Fingerprint = GenerateFingerprint(privateKey.Public().(ed25519.PublicKey))

	return identity, nil
}

// GenerateClientCert generates a client certificate signed by this identity
func (id *Identity) GenerateClientCert(commonName string, validDays int) (certPEM, keyPEM []byte, err error) {
	// Generate new keypair for client
	pub, priv, err := ed25519.GenerateKey(rand.Reader)
	if err != nil {
		return nil, nil, err
	}

	now := time.Now()
	serialNumber, err := rand.Int(rand.Reader, new(big.Int).Lsh(big.NewInt(1), 128))
	if err != nil {
		panic("crypto/rand failed: " + err.Error())
	}

	template := &x509.Certificate{
		SerialNumber: serialNumber,
		Subject: pkix.Name{
			CommonName:   commonName,
			Organization: []string{"Nitella"},
		},
		NotBefore:   now,
		NotAfter:    now.AddDate(0, 0, validDays),
		KeyUsage:    x509.KeyUsageDigitalSignature,
		ExtKeyUsage: []x509.ExtKeyUsage{x509.ExtKeyUsageClientAuth},
	}

	certDER, err := x509.CreateCertificate(rand.Reader, template, id.RootCert, pub, id.RootKey)
	if err != nil {
		return nil, nil, err
	}

	certPEM = pem.EncodeToMemory(&pem.Block{Type: "CERTIFICATE", Bytes: certDER})
	pkcs8Key, _ := x509.MarshalPKCS8PrivateKey(priv)
	keyPEM = pem.EncodeToMemory(&pem.Block{Type: "PRIVATE KEY", Bytes: pkcs8Key})

	return certPEM, keyPEM, nil
}

// GenerateEmojiHash generates a visual emoji hash from a public key
func GenerateEmojiHash(pubKey ed25519.PublicKey) string {
	hash := sha256.Sum256(pubKey)
	// Use first 8 bytes for 8 emojis
	var emojis []string
	for i := 0; i < 8; i++ {
		idx := int(hash[i]) % len(emojiSet)
		emojis = append(emojis, emojiSet[idx])
	}
	return strings.Join(emojis, "")
}

// GenerateFingerprint generates a hex fingerprint from a public key
func GenerateFingerprint(pubKey ed25519.PublicKey) string {
	hash := sha256.Sum256(pubKey)
	return hex.EncodeToString(hash[:])
}

// entropyToMnemonic converts entropy bytes to BIP-39 mnemonic words
func entropyToMnemonic(entropy []byte) string {
	// Simple implementation - in production use proper BIP-39 library
	// This creates a deterministic word list from entropy

	// Add checksum
	hash := sha256.Sum256(entropy)
	checksumBits := len(entropy) * 8 / 32

	// Combine entropy and checksum
	combined := make([]byte, len(entropy)+1)
	copy(combined, entropy)
	combined[len(entropy)] = hash[0]

	// Convert to 11-bit words
	var words []string
	wordCount := (len(entropy)*8 + checksumBits) / 11

	for i := 0; i < wordCount; i++ {
		// Extract 11 bits starting at bit position i*11
		bitPos := i * 11
		bytePos := bitPos / 8
		bitOffset := bitPos % 8

		// Read up to 3 bytes into a 24-bit value to safely extract 11 bits
		// This handles all cases where 11 bits may span 2 or 3 bytes
		var bits uint32
		bits = uint32(combined[bytePos]) << 16
		if bytePos+1 < len(combined) {
			bits |= uint32(combined[bytePos+1]) << 8
		}
		if bytePos+2 < len(combined) {
			bits |= uint32(combined[bytePos+2])
		}

		// Shift right to align the 11 bits we want, then mask
		value := int((bits >> uint(13-bitOffset)) & 0x7FF)

		wordIdx := value % len(bip39Words)
		words = append(words, bip39Words[wordIdx])
	}

	return strings.Join(words, " ")
}

// mnemonicToSeed converts a mnemonic to a seed using BIP-39 standard PBKDF2
func mnemonicToSeed(mnemonic string) []byte {
	// BIP-39 standard: PBKDF2 with HMAC-SHA512, 2048 iterations
	// password = mnemonic, salt = "mnemonic" + passphrase (empty passphrase for nitella)
	return pbkdf2.Key([]byte(mnemonic), []byte("mnemonic"), 2048, 64, sha512.New)
}

// ValidateMnemonic checks if a mnemonic is valid
func ValidateMnemonic(mnemonic string) bool {
	words := strings.Fields(mnemonic)
	if len(words) != 12 && len(words) != 24 {
		return false
	}

	wordSet := make(map[string]bool)
	for _, w := range bip39Words {
		wordSet[w] = true
	}

	for _, w := range words {
		if !wordSet[strings.ToLower(w)] {
			return false
		}
	}

	return true
}

// GetDataDir returns the default data directory for nitella
func GetDataDir(appName string) (string, error) {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	return filepath.Join(homeDir, "."+appName), nil
}

// ============================================================================
// Paired Node Certificate Storage
// ============================================================================

// SaveNodeCert saves a signed node certificate to the nodes directory
func SaveNodeCert(dataDir, nodeID string, certPEM []byte) error {
	nodesDir := filepath.Join(dataDir, "nodes")
	if err := os.MkdirAll(nodesDir, 0700); err != nil {
		return fmt.Errorf("failed to create nodes directory: %w", err)
	}

	// Sanitize nodeID for filename (replace unsafe chars)
	safeNodeID := sanitizeFilename(nodeID)
	certPath := filepath.Join(nodesDir, safeNodeID+".crt")

	if err := os.WriteFile(certPath, certPEM, 0644); err != nil {
		return fmt.Errorf("failed to save node certificate: %w", err)
	}

	return nil
}

// LoadNodeCert loads a node certificate from the nodes directory
func LoadNodeCert(dataDir, nodeID string) ([]byte, error) {
	safeNodeID := sanitizeFilename(nodeID)
	certPath := filepath.Join(dataDir, "nodes", safeNodeID+".crt")

	certPEM, err := os.ReadFile(certPath)
	if err != nil {
		return nil, fmt.Errorf("failed to read node certificate: %w", err)
	}

	return certPEM, nil
}

// LoadNodePublicKey loads a node's public key from its stored certificate
func LoadNodePublicKey(dataDir, nodeID string) (ed25519.PublicKey, error) {
	certPEM, err := LoadNodeCert(dataDir, nodeID)
	if err != nil {
		return nil, err
	}

	block, _ := pem.Decode(certPEM)
	if block == nil {
		return nil, errors.New("failed to decode certificate PEM")
	}

	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return nil, fmt.Errorf("failed to parse certificate: %w", err)
	}

	pubKey, ok := cert.PublicKey.(ed25519.PublicKey)
	if !ok {
		return nil, errors.New("certificate does not contain Ed25519 public key")
	}

	return pubKey, nil
}

// ListPairedNodes returns a list of all paired node IDs
func ListPairedNodes(dataDir string) ([]string, error) {
	nodesDir := filepath.Join(dataDir, "nodes")
	entries, err := os.ReadDir(nodesDir)
	if err != nil {
		if os.IsNotExist(err) {
			return []string{}, nil
		}
		return nil, fmt.Errorf("failed to read nodes directory: %w", err)
	}

	var nodeIDs []string
	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}
		name := entry.Name()
		if strings.HasSuffix(name, ".crt") {
			nodeIDs = append(nodeIDs, strings.TrimSuffix(name, ".crt"))
		}
	}

	return nodeIDs, nil
}

// DeleteNodeCert deletes a node certificate from the nodes directory
func DeleteNodeCert(dataDir, nodeID string) error {
	safeNodeID := sanitizeFilename(nodeID)
	certPath := filepath.Join(dataDir, "nodes", safeNodeID+".crt")
	return os.Remove(certPath)
}

// sanitizeFilename replaces unsafe characters in filename
func sanitizeFilename(name string) string {
	// Replace characters that are unsafe in filenames
	replacer := strings.NewReplacer(
		"/", "_",
		"\\", "_",
		":", "_",
		"*", "_",
		"?", "_",
		"\"", "_",
		"<", "_",
		">", "_",
		"|", "_",
	)
	return replacer.Replace(name)
}
