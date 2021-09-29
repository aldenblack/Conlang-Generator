using Random
include("data.jl") #(Datastructure to query how everything relates to one another. if all else fails, do popping from a set and rejecting probablistically)

function buildPhoneticInventory(seed) 
	consonantInventory = buildConsonantInventory(seed)
	return IPAphoneticInventory(consonantInventory, [])
end

function sameWithMargin(randval, base, margin)
	return randval < margin ? !base : base
end

function buildConsonantInventory(seed)
	rng = MersenneTwister(seed)
	consonantInventory::Array{IPAconsonant} = []
	#CONSONANTS

	#PULMONIC
	#Pick main rows and columbs
	#Voice distinction?
	#Aspiration distinction?
	#Affricates
	# Prenazalize
	
	# Primer set ?

	# PHONEMIC DISTINCTIONS

	# Plosive Series
	pVoicing = rand(rng) < 0.5
	pAspiration = rand(rng) < 0.35
	if pVoicing && pAspiration
		randval = rand(rng)
		if randval < 0.3 # 3/10 chance of just aspiration
			pVoicing = false
		elseif randval < 0.7 # 4/10 chance of just voicing
			pAspiration = false
		end # 3/10 chance to keep both
	end

	prenasalize = !(pVoicing && pAspiration) && rand(rng) < 0.1
	pLength = rand(rng) < 0.02 # May not be used


	# Fricative Series

	fVoicing = sameWithMargin(rand(rng), pVoicing,0.01)
	fAspiration = sameWithMargin(rand(rng), pVoicing,0.01)
	fLength = rand(rng) < 0.1 && !fAspiration # no fricative length and aspiration. can remove

	# Affricate Series
	affricates = rand(rng) < 1 # Edit value

	# Nasal Series
	nVoicing = rand(rng) < 0.03

	# Liquid Series
	#check what series exist, or if it's just the common ones
	lApprox = rand(rng) < 0.01
	lLateral = rand(rng) < 0.05 # from Phoible dataset
	#j and l common, also have consideration for a full lateral series


	# Coarticulated phonemes
	#check existence of k/p or g/b and voicing distintion
	#w and others



	# PHONEME CONSTRUCTION

	
	# Generate Primary Places

	bilabial = rand(rng) < 0.98 # Bilabial Trill problem
	labiodental = rand(rng) < 0.60 # f v should take bilabial precedent?
	alveolar = rand(rng) < 0.999
	dentalization = rand(rng) < 0.10
	retroflex = rand(rng) < 0.20
	palatal = rand(rng) < 0.20 
	velar = rand(rng) < 0.90
	uvular = rand(rng) < 0.10
	# Various specials, likek pharyngeal/glottal fricatives, glottal stop, w, l, y are independent.
	# TODO: Add something like with pVoicing/Aspiration where it *can* have all, but unbiasedly leans towards less.
	# TODO: Situations where there's just bilabial + alveolar w/ voicing should be *very* unlikely, since usually at least one back group will also exist. Number of places should re-impact places later on.

	places = [bilabial, labiodental, false, alveolar, false, retroflex, palatal, velar, uvular]

	# Nasal Series
	for place in 1:length(places)
		if places[place]
			currentConsonant = IPApulmonicConsonants[NASAL][place]
			if place > 2 # if not labial, give an extra chance to skip.
				if rand(rng) < 0.95
					push!(consonantInventory, IPAconsonant(currentConsonant[2], get(pulmonicPlaces, place, "ERROR"), "Nasal", true, []))
				end
			else
				if place == 2 # labiodental nasal is rare
					mod = bilabial ? 0 : 0.7
					rand(rng) < 0.05+mod ? push!(consonantInventory, IPAconsonant(currentConsonant[2], get(pulmonicPlaces, place, "ERROR"), "Nasal", true, [])) : nothing 
				else
					push!(consonantInventory, IPAconsonant(currentConsonant[2], get(pulmonicPlaces, place, "ERROR"), "Nasal", true, []))
				end
			end
		end
	end
	# Add voiceless nasals (run again, but with voice=1)

	# TODO: Make each series a separate function with params generated here.

	# Plosive Series
	startvoice = rand(rng) < 0.5 ? 1 : 2 # Primary voicing for languages without distinction.
	voice = startvoice # startvoice for fricative coherence
	voice2 = rand(rng) < 0.5 ? voice : 3-voice # For 
	for place in 1:length(places)
		# if dentalized, different for alveolar. do check inside other one.
		if places[place]
			currentConsonant = IPApulmonicConsonants[PLOSIVE][place]
			if pVoicing && !pAspiration 
				voice = 1
				rand(rng) < 0.95 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Plosive", Bool(voice-1), [])) : nothing
				voice = 2
				rand(rng) < 0.95 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Plosive", Bool(voice-1), [])) : nothing
			elseif !pVoicing && pAspiration
				voice = rand(rng) < 0.90 ? voice : 3-voice # 1/10 chance to swap voice for non-voice-distinguishing langs
				rand(rng) < 0.95 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Plosive", Bool(voice-1), [])) : nothing
				#voice2, may end up odd if voice swaps midway. theoretically this is another separate construction method
				rand(rng) < 0.95 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice2], get(pulmonicPlaces, place, "ERROR"), "Plosive", Bool(voice-1), [ʰ])) : nothing 
			elseif pVoicing && pAspiration
				voice = 1
				rand(rng) < 0.95 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Plosive", Bool(voice-1), [])) : nothing 
				rand(rng) < 0.95 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Plosive", Bool(voice-1), [ʰ])) : nothing 
				voice = 2
				rand(rng) < 0.95 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Plosive", Bool(voice-1), [])) : nothing
				rand(rng) < 0.95 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Plosive", Bool(voice-1), [ʰ])) : nothing 
			else # No voicing or aspiration
				voice = rand(rng) < 0.90 ? voice : 3-voice # Aspiration not phonemic, ergo left unwritten. Voice purely for aesthetics and choosing the phoneme char.
				rand(rng) < 0.95 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Plosive", Bool(voice-1), [])) : nothing
			end
		end
	end

	# dentalized check
	# may be worth upping the chance pairs come together from 1/20
	# Change from 1/20 chance to get each to a 1/10 chance to not have that place, 
	#plus a much lower chance to be asymmetric with the pairs.

	# Fricative Series 
	for place in 1:length(places) # TOOD: Handle bilab, dent, postalv
		if places[place]
			currentConsonant = IPApulmonicConsonants[FRICATIVE][place]
			if fVoicing && !fAspiration 
				voice = 1
				rand(rng) < 0.95 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Fricative", false, [])) : nothing
				voice = 2
				rand(rng) < 0.95 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Fricative", false, [])) : nothing
			elseif !fVoicing && fAspiration
				voice = rand(rng) < 0.90 ? voice : 3-voice # 1/10 chance to swap voice for non-voice-distinguishing langs
				rand(rng) < 0.95 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Fricative", false, [])) : nothing
				#voice2; may end up odd if voice swaps midway. theoretically this is another separate construction method
				rand(rng) < 0.95 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice2], get(pulmonicPlaces, place, "ERROR"), "Fricative", false, [ʰ])) : nothing 
			elseif fVoicing && fAspiration
				voice = 1
				rand(rng) < 0.95 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Fricative", false, [])) : nothing 
				rand(rng) < 0.95 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Fricative", false, [ʰ])) : nothing 
				voice = 2
				rand(rng) < 0.95 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Fricative", false, [])) : nothing
				rand(rng) < 0.95 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Fricative", false, [ʰ])) : nothing 
			else # No voicing or aspiration
				voice = rand(rng) < 0.90 ? voice : 3-voice # Aspiration not phonemic, ergo left unwritten. Voice purely for aesthetics and choosing the phoneme char.
				rand(rng) < 0.95 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Fricative", false, [])) : nothing
			end
		end
	end # TODO fix pɸ / pf problem and frequency of ɸ

	# 0.05 chance for dental fricatives, joined with the alveolar chance. In dentalized ones, one or the other?

	# Clean impossible/unused phonemes
	# Add cleaning of possible repeats, if they appear, or make output a set.
	index = 1
	while index <= length(consonantInventory)
		if consonantInventory[index].phoneme == '%' || consonantInventory[index].phoneme == '*'
			popat!(consonantInventory, index)
		else
			index += 1
		end
	end # Make a note: Get some public domain phoneme assets so people can hear their language being spoken

	# Affricate Series
	#https://en.wikipedia.org/wiki/Affricate
	# Does not include alvelo-palatal fricatives or other more specific 
	#coarticulated phonemes, unless I add them to the other functions as replacements.
	if affricates
	for consonant in consonantInventory
		if consonant.manner == "Plosive"
			placepos = eval(Meta.parse(uppercase(consonant.place))) 
			println(consonant)
			println(consonant.voice)
			println(Int(consonant.voice)+1)
			affricate = IPAconsonant(consonant.phoneme*IPApulmonicConsonants[FRICATIVE][placepos][Int(consonant.voice)+1], consonant.place, "Affricate", consonant.voice, consonant.diacritics)
			# Find a way to, rather than making a new IPAconsonant, check all in consonantInventory(.phoneme)s
			# Current method requires multiple checks for each diacritic array.
			#if IPAconsonant(IPApulmonicConsonants[FRICATIVE][placepos][Int(consonant.voice)+1], consonant.place, "Fricative", consonant.voice, []) in consonantInventory || IPAconsonant(IPApulmonicConsonants[FRICATIVE][mannerpos][Int(consonant.voice)+1], consonant.place, "Fricative", consonant.voice, [ʰ]) in consonantInventory
			if IPApulmonicConsonants[FRICATIVE][placepos][Int(consonant.voice)+1] in [c.phoneme for c in consonantInventory]
				push!(consonantInventory, affricate)
			else
				rand(rng) < 1 ? push!(consonantInventory, affricate) : nothing #0.2
			end
		end
	end # TODO Current system disallows things like "dva" as a single phonemic element.
	end # Also disallows ch, so the logic should go from the fricative rather than the plosive, since sh and ch double up on t, though the latter postalveolarizes non-phonemically.
	# broad diacritic saving or specific?

	# Liquid Series
	for place in 1:length(places)

	# TODO draw a map of what currently impacts what; for instance, there's no odds for affricates. They just all are or all aren't - except somehow not always. Examine 6710414268 further.

	#NON-PULMONIC
	#If there's one click, it's more likely to add others. 
	# 1235 n||

	# could do accept-reject

	# DEBUG PRINTS
	println("PLACES")
	println("Bilabial: " * string(bilabial))
	println("Labiodental: " * string(labiodental))
	println("Alveolar: " * string(alveolar))
	println("Retroflex: " * string(retroflex))
	println("Palatal: " * string(palatal))
	println("Velar: " * string(velar))
	println("Uvular: " * string(uvular))
	println("MANNER MODIFIERS")
	println("pVoicing: " * string(pVoicing))
	println("pAspiration: " * string(pAspiration))
	println("prenasalize: " * string(prenasalize))
	println("fVoicing: " * string(fVoicing))
	println("fAspiration: " * string(fAspiration))
	println("fLength: " * string(fLength))
	println("Affricates:" * string(affricates))
	println("Appriximate Group: " * string(lApprox))
	println("Lateral Group: " * string(lLateral))
	println("Rhotic/RhoticVowels distinction")


	return consonantInventory
end

function buildNasalSeries(seed, consonantInventory, places, bilabial)
	return
end

function buildVowelInventory(seed)
	#VOWELS
	#length distinction
	#breathy/creaky voice
	#Phonemic nasalization, or just in combination? 0.02 chance # It's phonemic, just from historical nasals
	#Tone

	# Group into 3-vowel system, 5-vowel system, common formations, and other
end

function buildPhonotactics(seed) 
	#(C)V(C), Word-initial, word-middle, word-final
	rng = MersenneTwister(seed)
	onset = 1
	coda = 0
	randval = rand(rng)
	onset += Int(floor(5*randval^2))
	randval = rand(rng)
	coda += Int(floor(5*randval^2))
	syllableStructure = (onset, coda)
	return syllableStructure
	#TODO: Turn probabilities into if-statement check to find exactly the distributions I want
	# Use curve-fitting algorithm (talk to kaleb laters)


	# Onsets and codas tend to be similar in max length
	# Greater than 5 is very rare
	# CCCVCCCC strengths
	# CVC is most common, CV is required

	# longer mid-words are much less likely; CCVCC usually has CC midword, or C
	# This does create a lack of sound bias and a very uniform layout (no likely e or m or something). Allow this at first but not later — Probably in the Lexeme function and not here.
	# USE SET FOR WORD-INITIAL ETC -- no need, it constructs itself organizedly

	#Stress system

end

function buildGrammaticalSystem(seed) 
	#create syntax structure, available cases, adpositions, pre/postpositions, how to use unavailable ones, etc.
# Artifexian logic table for adposition ordering and SVO-SOV
	#SVO probability
end

function buildMorphology(seed)
	#assigns phonemes to grammatical system, pre/post placements, and (crucially) derivational morphology

end

function buildLexemes(seed)
	#creates the broader units of meaning, then builds words
	#define words with type and definition, possibly include way for overlap

# yīchtū /ˈjiːʧtuː/ n. choice
# kyēkītchī /kjeːˈkiːtʧiː/ n. bug 


end



function main()
	#Data.initializeData()
	seed = Int(trunc(rand()*(10^10)))
	@info seed
	phoneticInventory = buildPhoneticInventory(seed) 
	println(phoneticInventory.consonants)
	phonemearray = []
	for p in phoneticInventory.consonants
		push!(phonemearray, getCharAndDiacritics(p))
	end
	#=for p in phoneticInventory.vowels
		push!(phonemearray, p.phoneme)
	end=#
	println(phonemearray)
	while true # DO WHILE?
		input = readline(stdin)
		if input == "reload" || input == "r"
			seed = Int(trunc(rand()*(10^10)))
			@info seed
			phoneticInventory = buildPhoneticInventory(seed)
			@info phoneticInventory
			phonemearray = []
			for p in phoneticInventory.consonants
				push!(phonemearray, getCharAndDiacritics(p))
			end
			#=for p in phoneticInventory.vowels
				push!(phonemearray, p.phoneme)
			end=#
			println(phonemearray)
		elseif input == "exit" || input == "q"
			break
		end 
	end
end

main()

# KEEP CURRENT VER OF PHONEME GENERATION AS BENCHMARK TO USE FOR LATER WITHOUT



# Storing too much in the ipaconsonant, probably don't do

# TODO:
# Explain the process in the comments to describe what the code is doing.
# Complete sentences, easy to read.






#TODO: 


# Manner affects what other manners have, like voicing and diacritics
# 
# Place only affects existence of other places in number
# y and l are rarer and less effect
# each manner has different probablistic selection function 
# or is grouped in selection process
# Plosive carries diacritic across the manner
# voicing affects things in other manners
# Labiodentals and bilabials are paired
#lots of functions that do the same thing in very different ways

# Have manners on the outside as the first thing to index
# For each place, keep track of how many total places are selected
# Affects across the manner column are the most notable, but diacritics
#still spread across manner within plosive, fricative, and affricate groups
# Manner to IPA character or IPAchar to manner?
# Array of diacritics *may* be right, or it should be bools in each Manner function
# Voicing and aspiration often cancel
# How to represent the characters and the voicing/diacritics in relation
#Test many things or do whatever's easiest. This will be most complex datastructure
# Either each consonant to diacritic or diacritic to place+manner (no, latter is extra)

# First select based on manner, then 

# new place labial-velar for coarticulated kp/gb and w


# VALUABLE QUESTION:
# How does each part of the consonant affect each part of the selection process?
# WRITE THIS OUT
