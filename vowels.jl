
function buildVowelInventory(seed)
	rng = MersenneTwister(seed)
	#VOWELS
	vowelInventory::Array{IPAvowel} = []
	#length distinction
	#breathy/creaky voice
	#Phonemic nasalization, or just in combination? 0.02 chance # It's phonemic, just from historical nasals
	#Tone

	# Group into 3-vowel system, 5-vowel system, common formations, and other
	val = rand(rng)
	vowelsystem = val < 0.15 ? 0 : ( val < 0.45 ? 1 : 2) # 0 - 3vowel, 1 - 5vowel, 2 - random other
	# Prioritize open in the front and round in the back.
	roundfront = rand(rng) < 0.3
	highnasal = rand(rng) < 0.1
	lownasal = rand(rng) 
	if vowelsystem == 0 
		v1options = [IPAvowel("i", "close", "front", false, []), IPAvowel("ɪ", "nearclose", "front", false, []), IPAvowel("e", "closemid", "front", false, [])]
		v1 = v1options[findfirst(cumsum([0.9, 0.08, 0.02]) .> rand(rng))] # test case 0.3, 0.3, 0.4
		v2options = [IPAvowel("a", "open", "front", false, []), IPAvowel("æ", "nearopen", "front", false, []), IPAvowel("e", "closemid", "front", false, [])]
		v2 = v2options[findfirst(cumsum([0.9, 0.08, 0.02]) .> rand(rng))] # FIXME: make e and ae less common for v1 and v2
		while true
			v2 = v2options[findfirst(cumsum([0.9, 0.08, 0.02]) .> rand(rng))] # 137397147 proof of e == e
			v1.phoneme != v2.phoneme && break
		end
		v3options = [IPAvowel("u", "high", "back", true, []), IPAvowel("o", "mid", "back", true, []), IPAvowel("ɯ", "high", "back", false, []),]
		v3 = v3options[findfirst(cumsum([0.9, 0.08, 0.02]) .> rand(rng))]
		push!(vowelInventory, v1)
		push!(vowelInventory, v2)
		push!(vowelInventory, v3)
	elseif vowelsystem == 1
		# Distance algorithm, select randomly based on what's far away from previous ones. (Or if distance algorithm has weird results, just use it for the >5 v system)
		fronts = 0
		backs = 0
		highs = 0
		lows = 0 # Count how many and try to balance, perhaps with a bit of a forward or backward lean depending on language.
	else
		close = true
		nearclose = rand(rng) < 0.5
		closemid = rand(rng) < 0.5
		mid = rand(rng) < 0.5
		openmid = rand(rng) < 0.5
		nearopen = rand(rng) < 0.5
		open = true 
		heights = [close, nearclose, closemid, mid, openmid, nearopen, open]

		for height in heights
			
		end
	end
	# Length, nasalization, breathy/creaky, etc. goes after over a for loop of the vowelInventory
	
	# Tone (Maybe include a tone graph.) 60%-ish of languages in natlangs

	return vowelInventory
end

function vowelSelection(rng, )
	# Preferential distance algorithm, in which certain features (like back roundness) are prioritized
	for height in 1:length(IPAvowels)
		for backness in 1:length(IPAvowels[height])
			IPAvowels[height, backness]
		end
	end
	
end