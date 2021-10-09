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
	buildFricativeSeries(rng, consonantInventory, places, fVoicing, fAspiration, fLength, primingvoice)

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
        buildAffricateSeries(rng, consonantInventory)
	end 
	
	# Trills
	# Liquid Series
	for place in 1:length(places)

	end

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
end

function buildPlosiveSeries(rng, consonantInventory, places, pVoicing, pAspiration, dentalization, prenasalize, primingvoice)
	voice = primingvoice # startvoice for fricative coherence
	voice2 = rand(rng) < 0.5 ? voice : 3-voice # For swapping, may end up unused. Currently in aspiration-only case.
	for place in 1:length(places)
		if places[place]
            currdiacritics = []
            (dentalization && place == 4) && push!(currdiacritics, dental)
            prenasalize && push!(currdiacritics, ⁿ)

			currentConsonant = IPApulmonicConsonants[PLOSIVE][place]
			if pVoicing && !pAspiration 
				voice = 1
				rand(rng) < 0.99 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Plosive", Bool(voice-1), currdiacritics)) : nothing
				voice = 2
				rand(rng) < 0.99 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Plosive", Bool(voice-1), currdiacritics)) : nothing
			elseif !pVoicing && pAspiration
				voice = rand(rng) < 0.90 ? voice : 3-voice # 1/10 chance to swap voice for non-voice-distinguishing langs
				rand(rng) < 0.99 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Plosive", Bool(voice-1), currdiacritics)) : nothing
				#voice2, may end up odd if voice swaps midway. theoretically this is another separate construction method
				rand(rng) < 0.99 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice2], get(pulmonicPlaces, place, "ERROR"), "Plosive", Bool(voice-1), vcat(currdiacritics, [ʰ]))) : nothing 
			elseif pVoicing && pAspiration
				voice = 1
				rand(rng) < 0.99 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Plosive", Bool(voice-1), currdiacritics)) : nothing 
				rand(rng) < 0.99 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Plosive", Bool(voice-1), vcat(currdiacritics, [ʰ]))) : nothing 
				voice = 2
				rand(rng) < 0.99 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Plosive", Bool(voice-1), currdiacritics)) : nothing
				rand(rng) < 0.99 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Plosive", Bool(voice-1), vcat(currdiacritics, [ʰ]))) : nothing 
			else # No voicing or aspiration
				voice = rand(rng) < 0.90 ? voice : 3-voice # Aspiration not phonemic, ergo left unwritten. Voice purely for aesthetics and choosing the phoneme char.
				rand(rng) < 0.99 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Plosive", Bool(voice-1), currdiacritics)) : nothing
			end
		end
	end
end

function buildFricativeSeries(rng, consonantInventory, places, fVoicing, fAspiration, fLength, primingvoice)
    voice = primingvoice
	voice2 = rand(rng) < 0.5 ? voice : 3-voice # NOTE: For swapping, may end up unused. Currently in aspiration-only case.
    places[3] = rand(rng) < 0.05; places[5] = rand(rng) < 0.25 # Handles dental and postalveolar fricatives. 
    place = 1 # While loop to stop labiodentals from being added twice, as in 6710414268 and 4544225130 NOTE: Mentioned seeds are somehow identical.
	while place <= length(places) 
		if places[place]
			place == 1 ? (rand(rng) < 0.95 ? place = 2 : nothing) : nothing # Handles Bilabial Fricatives
			currentConsonant = IPApulmonicConsonants[FRICATIVE][place]
			if fVoicing && !fAspiration 
				voice = 1
				rand(rng) < 0.99 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Fricative", false, [])) : nothing
				voice = 2
				rand(rng) < 0.99 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Fricative", false, [])) : nothing
			elseif !fVoicing && fAspiration
				voice = rand(rng) < 0.90 ? voice : 3-voice # 1/10 chance to swap voice for non-voice-distinguishing langs
				rand(rng) < 0.99 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Fricative", false, [])) : nothing
				#voice2; may end up odd if voice swaps midway. theoretically this is another separate construction method
				rand(rng) < 0.99 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice2], get(pulmonicPlaces, place, "ERROR"), "Fricative", false, [ʰ])) : nothing 
			elseif fVoicing && fAspiration
				voice = 1
				rand(rng) < 0.99 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Fricative", false, [])) : nothing 
				rand(rng) < 0.99 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Fricative", false, [ʰ])) : nothing 
				voice = 2
				rand(rng) < 0.99 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Fricative", false, [])) : nothing
				rand(rng) < 0.99 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Fricative", false, [ʰ])) : nothing 
			else # No voicing or aspiration
				voice = rand(rng) < 0.90 ? voice : 3-voice # Aspiration not phonemic, ergo left unwritten. Voice purely for aesthetics and choosing the phoneme char.
				rand(rng) < 0.99 ? push!(consonantInventory, IPAconsonant(currentConsonant[voice], get(pulmonicPlaces, place, "ERROR"), "Fricative", false, [])) : nothing
			end
		end
        place += 1
    end 
end

function buildAffricateSeries(rng, consonantInventory)
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


