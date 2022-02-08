function buildConsonantInventory(seed)
	rng = MersenneTwister(seed)
	consonantInventory::Array{IPAconsonant} = []
	#CONSONANTS

	#PULMONIC

	# PHONEMIC DISTINCTIONS

	# Plosive Series
	pVoicing = rand(rng) < 0.5
	pAspiration = rand(rng) < 0.35
	if pVoicing && pAspiration
		randval = rand(rng)
		if randval < 0.4 # 4/10 chance of just aspiration
			pVoicing = false
		elseif randval < 0.95 # 5.5/10 chance of just voicing
			pAspiration = false
		end # 0.5/10 chance to keep both
	end

	prenasalize = !(pVoicing && pAspiration) && rand(rng) < 0.1
	pLength = rand(rng) < 0.02 # May not be used


	# Fricative Series

	fVoicing = sameWithMargin(rand(rng), pVoicing,0.01)
	fAspiration = sameWithMargin(rand(rng), pVoicing,0.01)
	fLength = rand(rng) < 0.08 && !fAspiration # No gemination and aspiration

	# Affricate Series
	affricates = rand(rng) < 1 # FIXME: Give probability

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
	# FIXME: Should be a set 

	bilabial = rand(rng) < 0.98 # Bilabial Trill problem 
	labiodental = rand(rng) < 0.60 # f v should take bilabial precedent?
	alveolar = rand(rng) < 0.999
	dentalization = rand(rng) < 0.05
	retroflex = rand(rng) < 0.20
	palatal = rand(rng) < 0.20 
	velar = rand(rng) < 0.90
	uvular = rand(rng) < 0.10
	# Various special phonemes, like pharyngeal/glottal fricatives, glottal stop, w, l, y are independent.
	# TODO: Add something like with pVoicing/Aspiration where it *can* have all, but unbiasedly leans towards less.
	# TODO: Situations where there's just bilabial + alveolar w/ voicing should be *very* unlikely, since usually at least one back group will also exist. Number of places should re-impact places later on.

	places = [bilabial, labiodental, false, alveolar, false, retroflex, palatal, velar, uvular]
    # Perhaps change the places array slightly so some of the lines are more broken.

	# Nasal Series
	buildNasalSeries(rng, consonantInventory, places, bilabial)
	# Add voiceless nasals (run again, but with voice=1)

	# TODO: Make each series a separate function with params generated here.

	# Plosive Series
    primingvoice = rand(rng) < 0.5 ? 1 : 2 # Primary voicing for languages without distinction.
	buildPlosiveSeries(rng, consonantInventory, places, pVoicing, pAspiration, dentalization, prenasalize, primingvoice)

	# dentalized check
	# may be worth upping the chance pairs come together from 1/20 (NOW 1/100)
	# Change from 1/20 chance to get each to a 1/10 chance to not have that place, 
	#plus a much lower chance to be asymmetric with the pairs.

	# Fricative Series 
	buildFricativeSeries(rng, consonantInventory, places, fVoicing, fAspiration, fLength, dentalization, primingvoice)

	# 0.05 chance for dental fricatives, joined with the alveolar chance. In dentalized ones, one or the other?

	# Clean impossible/unused phonemes
	# TODO: Add cleaning of possible repeats, if they appear, or make output a set.
	index = 1
	while index <= length(consonantInventory)
		if consonantInventory[index].phoneme == '%' || consonantInventory[index].phoneme == '*'
			popat!(consonantInventory, index)
		else
			index += 1
		end
	end # NOTE: Get some public domain phoneme assets so people can hear their language being spoken

	# Affricate Series
	#https://en.wikipedia.org/wiki/Affricate
	# Does not include alvelo-palatal fricatives or other more specific 
	#coarticulated phonemes, unless I add them to the other functions as replacements.
	if affricates
        buildAffricateSeries(rng, consonantInventory)
	end 
	
	# Trills
	# Liquid Series
	buildLiquidSeries(rng, consonantInventory, places, fVoicing, fAspiration, fLength, lApprox, lLateral)

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

function buildNasalSeries(rng, consonantInventory, places, bilabial)
	for place in 1:length(places)
		if places[place]
			currentPlace = get(pulmonicPlaces, place, "ERROR")
			currentConsonant = IPApulmonicConsonants[NASAL][place]
			
			if place > 2 # if not labial, give an extra chance to skip.
				pushToInventory(rng, 0.95, consonantInventory, currentConsonant, 2, currentPlace, "Nasal", [])
			else
				if place == 2 # labiodental nasal is rare
					mod = bilabial ? 0 : 0.7
					pushToInventory(rng, 0.05+mod, consonantInventory, currentConsonant, 2, currentPlace, "Nasal", [])
				else
					pushToInventory(rng, 1, consonantInventory, currentConsonant, 2, currentPlace, "Nasal", [])
				end
			end
		end
	end
end

function buildPlosiveSeries(rng, consonantInventory, places, pVoicing, pAspiration, dentalization, prenasalize, primingvoice)
	if pVoicing
		voices = [1, 2]
	else
		voices = [primingvoice]
	end

	for place in 1:length(places)
		rand(rng) < 0.7 ? aspiration = [ʰ, nothing] : aspiration = [nothing, ʰ] # For pVoice !pAsp
		if places[place]
            currdiacritics = []
            (place == 4 && dentalization) && push!(currdiacritics, dental)

			currentConsonant = IPApulmonicConsonants[PLOSIVE][place]
			currentPlace = get(pulmonicPlaces, place, "ERROR")
			### A language will fall into one of these categories: 
			# p b
			# p b ⁿb
			# pʰ b
			# pʰ b ⁿb
			# p bʰ
			# p bʰ ⁿb
			# pʰ p
			# pʰ p ⁿb
			# b bʰ
			# b bʰ ⁿb
			# p pʰ b bʰ
			### 
 			aspirindex = 1 # swap aspiration for voiced but not aspirated
			for voice in voices
				 ʰ in currdiacritics ? pop!(currdiacritics) : nothing # Clear aspiration from previous voice in pVoice !pAsp
				if prenasalize && voice == 2
					pushToInventory(rng, 0.99, 
						consonantInventory, currentConsonant, voice, currentPlace, "Plosive", vcat(currdiacritics, [ⁿ]))
				end
				if pVoicing && !pAspiration
					aspiration[aspirindex] != nothing ? push!(currdiacritics, aspiration[aspirindex]) : nothing
					aspirindex = 3-aspirindex
				end
				if rand(rng) < 0.90 # Assymetry for block
					pushToInventory(rng, 0.96, 
							consonantInventory, currentConsonant, voice, currentPlace, "Plosive", currdiacritics)
					if pAspiration
						pushToInventory(rng, 0.96, 
							consonantInventory, currentConsonant, voice, currentPlace, "Plosive", vcat(currdiacritics, [ʰ]))
					end
				end
			end

			if !pVoicing # 1/10 chance to swap voice for non-voice-distinguishing langs
				voices[1] = rand(rng) < 0.10 ? 3-voices[1] : voices[1] 
			end
		end
	end
end

function buildFricativeSeries(rng, consonantInventory, places, fVoicing, fAspiration, fLength, dentalization, primingvoice)
    places[3] = rand(rng) < 0.05 + (dentalization/1.25); places[5] = rand(rng) < 0.25 # Handles dental and postalveolar fricatives. 
	dentalization ? (places[4] ? places[4] = rand(rng) < 0.6 : nothing) : nothing
    place = 1 # While loop to stop labiodentals from being added twice, as in 6710414268 and 4544225130 NOTE: Mentioned seeds are somehow identical.
	if fVoicing
		voices = [1, 2]
	else
		voices = [primingvoice] #FIXME: Same way that pb -> fv, make kg -> h instead of x sometimes.
	end
	diacritics = []
	if fAspiration; push!(diacritics, ʰ); end
	if fLength; push!(diacritics, ː); end
	swapvelar = false
	while place <= length(places) 
		if places[place]
			if place == BILABIAL; if rand(rng) < 0.95; place = 2; end; end # Handles Bilabial Fricatives
			#if place == VELAR; if !places[GLOTTAL]; if rand(rng) < 0.95; place = GLOTTAL; swapvelar = true; end; end; end # randomly skips whole sections in all languages with k-series and h.
			currentPlace = get(pulmonicPlaces, place, "ERROR")
			currentConsonant = IPApulmonicConsonants[FRICATIVE][place]
			if rand(rng) < 0.90 # Assymetry for block
				for voice in voices
					pushToInventory(rng, 0.95, consonantInventory, currentConsonant, voice, currentPlace, "Fricative", [])
					if place == GLOTTAL && rand(rng) < 0.25 # Less likely to have variation for h
					for diacritic in diacritics # should only be one or the other
						pushToInventory(rng, 
							0.95, consonantInventory, currentConsonant, voice, currentPlace, "Fricative", [diacritic])
					end
					end
				end
			end

			if !fVoicing # Chance to swap voicing
				voices[1] = rand(rng) < 0.10 ? 3-voices[1] : voices[1]
			end
		end
		if swapvelar; place = VELAR+1; end
        place += 1
    end # TODO: fix pɸ / pf problem and frequency of ɸ (affricate-only problem)
end # Even pf is very rare, so make bilabial affricates go through an extra layer of heavy scrutiny. 
# FIXME: prenasalization frequency and "pɸⁿ", "bβⁿ", "tsⁿ", "dzⁿ", "kxⁿ", "ɡɣⁿ" in language with "pⁿ", "bⁿ", "tⁿ", "dⁿ", "kⁿ" (INCLUDE NONPRENASALIZED)


# 3189368585 "t̪", "t̪ʰ", "k", "kʰ", "f", "fː", "θ", "θː", "s", "sː", "x", "xː", "pɸ", "pɸʰ", "t̪s", "t̪sʰ", etc should be "t̪θ" and have no length or aspiration


function buildAffricateSeries(rng, consonantInventory) #TODO: Each affricate should be far less likely than its fricative counterpart, but should still come in pairs/groups.
    for consonant in consonantInventory
		if consonant.manner == "Plosive"
			placepos = eval(Meta.parse(uppercase(consonant.place))) 
			println(consonant)
			println(consonant.voice)
			println(Int(consonant.voice)+1)
			affricate = IPAconsonant(consonant.phoneme*IPApulmonicConsonants[FRICATIVE][placepos][Int(consonant.voice)+1], consonant.place, "Affricate", consonant.voice, consonant.diacritics)
			# Find a way to, rather than making a new IPAconsonant, check all in consonantInventory(.phoneme)s
			# Current method requires multiple checks for each diacritic array.
			# Add a possibility where even for aspirated consonant langs it doesn't add aspirated fricatives.
			if IPApulmonicConsonants[FRICATIVE][placepos][Int(consonant.voice)+1] in [c.phoneme for c in consonantInventory]
				push!(consonantInventory, affricate) # TODO: kɣʰ has very strange voicing...
			else
				rand(rng) < 1 ? push!(consonantInventory, affricate) : nothing #TODO: Change back to 0.2
			end
		end
	end # TODO: Current system disallows things like "dva" as a single phonemic element.
    # Also disallows ch, so the logic should go from the fricative rather than the plosive, since sh and ch double up on t, though the latter postalveolarizes non-phonemically.
	# broad diacritic saving or specific?
end

function buildLiquidSeries(rng, consonantInventory, places, fVoicing, fAspiration, fLength, lApprox, lLateral)
	# Most language will have some variation on w, l and r-like sounds
	#TODO: toss in lateral fricative in buildFricativeSeries

	
	if lApprox
	for place in 1:length(places)
		
		if places[place]
            pushToInventory(rng, 
							0.95, consonantInventory, currentConsonant, voice, currentPlace, "Lateral Approximant", [])

		end
	end
	end
	if lLateral

	end
	# w and ʍ (coarticulated phonemes - tack onto the end and stick in a separate box, as well as with clicks).

end

# Languages with clicks tend to have a lot, and never just one. Bilabial is rare.

function pushToInventory(rng, probability, consonantInventory, currentConsonant, voice, place, manner::String, diacritics)
	rand(rng) < probability ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], place, manner, voice-1, diacritics)) : nothing
end

# FIXME: Include posibility that each Place has only a few instances rather than an almost surely dedicated row (i. e. only ç and j but not c or anything else)