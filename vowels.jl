using Random
#include("data.jl")
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
	highnasal = rand(rng) < 0.1 # closenasal
	lownasal = rand(rng) #opennasal - do a region selection where sometimes single rows get removed amid the rest, or whole columns
	if vowelsystem == 0 
		v1options = [IPAvowel("i", "close", "front", false, []), IPAvowel("ɪ", "nearclose", "front", false, []), IPAvowel("e", "closemid", "front", false, [])]
		v1 = v1options[findfirst(cumsum([0.9, 0.08, 0.02]) .> rand(rng))] # test case 0.3, 0.3, 0.4
		v2options = [IPAvowel("a", "open", "front", false, []), IPAvowel("æ", "nearopen", "front", false, []), IPAvowel("e", "closemid", "front", false, [])]
		v2 = v2options[findfirst(cumsum([0.9, 0.08, 0.02]) .> rand(rng))] # FIXME: make e and ae less common for v1 and v2
		while true
			v2 = v2options[findfirst(cumsum([0.9, 0.08, 0.02]) .> rand(rng))] # 137397147 proof of e == e
			v1.phoneme != v2.phoneme && break
		end
		v3options = [IPAvowel("u", "close", "back", true, []), IPAvowel("o", "closemid", "back", true, []), IPAvowel("ɯ", "close", "back", false, []),]
		v3 = v3options[findfirst(cumsum([0.9, 0.08, 0.02]) .> rand(rng))]
		push!(vowelInventory, v1)
		push!(vowelInventory, v2)
		push!(vowelInventory, v3)
	elseif vowelsystem == 1
		vowelInventory = [
			[IPAvowel("i", "close", "front", false, []), IPAvowel("ɪ", "nearclose", "front", false, [])][findfirst(
				cumsum([0.75, 0.25]) .> rand(rng))],
			[IPAvowel("e", "closemid", "front", false, []), IPAvowel("ɛ", "openmid", "front", false, [])][findfirst(
				cumsum([0.5, 0.5]) .> rand(rng))],
			[IPAvowel("a", "open", "front", false, []), IPAvowel("æ", "nearopen", "front", false, [])][findfirst(
				cumsum([0.99, 0.01]) .> rand(rng))],
			[IPAvowel("o", "closemid", "back", true, []), IPAvowel("ɔ", "openmid", "back", true, [])][findfirst(
				cumsum([0.5, 0.5]) .> rand(rng))],
			[IPAvowel("u", "close", "back", true, []), IPAvowel("ʊ", "nearclose", "back", true, [])][findfirst(
				cumsum([0.9, 0.1]) .> rand(rng))]
		]
	else
		# RANDOM VOWEL SYSTEM; scale to consonant count. 

		#Dictionary of vowels; update probability every time so it adds up to 1. Remove and update all probabilities by distance.
		#Nasals should be a second phase so it only chooses vowels that are already in the language
		
		# highest probability: Front unrounded vowels and back rounded vowels that aren't in an even position.
		vWeights = Dict()
		for vy in 1:length(IPAvowels)
			for vx in 1:length(IPAvowels[1])
				for vr in 1:2
					if IPAvowels[vy][vx][vr] != '*'
						vWeight = 2
						if !(vy%2==0); vWeight += 8; end # Boost the odd rows with the vowels that aren't "intermediate"
						if ((vx==1 && vr==1) || (vx==3 && vr==2 && vy<6)); vWeight += 10; end # Boost the rows with vowels that are front unrounded or back rounded.
						if (vy%2==0); vWeight ÷= 2; end
						vWeights[IPAvowels[vy][vx][vr]] = vWeight
					end
				end
			end
		end
		println(vWeights)
		while true
			selectWeightedVowel(rng, vowelInventory, vWeights)
			if length(vowelInventory) >= 4
				rand(rng) < ( -2/length(vowelInventory)+0.51 ) && break
			end
		end
		println(vowelInventory) 
		
		#i->ɪ - length or stressedness distinction (outside of this if statement)

	end
	# Length, nasalization, breathy/creaky, etc. goes after over a for loop of the vowelInventory
	# Diphthongs
	
	# Tone (Maybe include a tone graph.) 60%-ish of languages in natlangs
	# Related to phonotactics generation - lexical or grammatical tone?

	return vowelInventory
end

function selectWeightedVowel(rng, vowelInventory, vWeights) 
	# Preferential distance algorithm, in which certain features (like back roundness) are prioritized
	keylist = [key for key in keys(vWeights)]
	valuelist = [vWeights[key] for key in keylist]
	position = findfirst(cumsum(valuelist) .>= (rand(rng)*sum(valuelist)))
	if isnothing(position) # when the cumsum == rand*sum (i.e. rand=1), a nothing value is returned
		position = length(valuelist)
	end
	vowel = keylist[position] 
	
	vowelpos = findVowelPosition(vowel)
	push!(vowelInventory, IPAvowel(vowel, vowelHeight[vowelpos[1]], vowelBackness[vowelpos[2]], vowelpos[3]-1, []))
	delete!(vWeights, vowel)
	return reweighVowels(vWeights, vowelInventory, vowelpos)
end

function reweighVowels(vWeights, vowelInventory, origin)
	for vy in 1:length(IPAvowels)
		for vx in 1:length(IPAvowels[1])
			for vr in 1:2
				if !(IPAvowels[vy][vx][vr] in [v.phoneme for v in vowelInventory] || IPAvowels[vy][vx][vr]=='*')
					distance = max(vy-origin[1], vx-origin[2])
					if distance != 0 # the rounding counterpart to the most recent vowel
						vWeights[IPAvowels[vy][vx][vr]] = vWeights[IPAvowels[vy][vx][vr]] / (2/distance)
					end
				end
			end
		end
	end 
end

function findVowelPosition(vowel::Char)
	for vy in 1:length(IPAvowels)
		for vx in 1:length(IPAvowels[1])
			for vr in 1:2
				if IPAvowels[vy][vx][vr] == vowel
					return [vy, vx, vr]
				end
			end
		end
	end
end