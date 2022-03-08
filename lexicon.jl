function buildLexemes(seed, phonolgy::IPAphoneticInventory, phonotactics)
	rng = MersenneTwister(seed)
	#creates the broader units of meaning, then builds words
	#define words with type and definition, possibly include way for overlap
	onset = phonotactics[1]
	coda = phonotactics[2]

	conlangLexicon = []
	for i in 1:size(vocabList)[1] 
		rawTranslation = vocabList[i, 3]
		definitions = vocabParser(rng, rawTranslation)
		if vocabList[i, 1] == "noun"
			for d in definitions
				conword = deriveTerm(rng, phonolgy, phonotactics, vocabList[i, 2], vocabList[i, 4], vocabList[i, 5])
				gender = fixGenderToConlang(rng, vocabList[i, 7])
				push!(conlangLexicon, Noun(d, conword, gender, vocabList[i, 6]))
			end
		elseif vocabList[i, 1] == "verb"
			for d in definitions
				conword = deriveTerm(rng, phonolgy, phonotactics, vocabList[i, 2], vocabList[i, 4], vocabList[i, 5])
				if '/' in vocabList[i, 7]
					transitivityoptions = split(vocabList[i, 7], '/')
					transitivity = transitivityoptions[rand(1:length(transitivityoptions))]
				else
					transitivity = vocabList[i, 7]
				end
				push!(conlangLexicon, Verb(d, conword, transitivity, vocabList[i, 7]=="dative")) 
			end
		elseif vocabList[i, 1] == "preposition"
			for d in definitions
				conword = deriveTerm(rng, phonolgy, phonotactics, vocabList[i, 2], vocabList[i, 4], vocabList[i, 5])
				push!(conlangLexicon, Adposition(d, conword))
			end
		elseif vocabList[i, 1] == "adjective"
			for d in definitions
				conword = deriveTerm(rng, phonolgy, phonotactics, vocabList[i, 2], vocabList[i, 4], vocabList[i, 5])
				push!(conlangLexicon, Adjective(d, conword, "Nominal", "Neuter"))
			end
		elseif vocabList[i, 1] == "adverb"
			for d in definitions
				conword = deriveTerm(rng, phonolgy, phonotactics, vocabList[i, 2], vocabList[i, 4], vocabList[i, 5])
				push!(conlangLexicon, Adverb(d, conword))
			end
		elseif vocabList[i, 1] == "conjunction"
			for d in definitions
				conword = deriveTerm(rng, phonolgy, phonotactics, vocabList[i, 2], vocabList[i, 4], vocabList[i, 5])
				push!(conlangLexicon, Adposition(d, conword))
			end
		end
	end # Good lexical generation: qχots, pɸɑf, npɶnts
	# Bad lexical generation: kxqχøk, χχʂɐx, kxkxʌsf, qχpɸɳɶtp 
	# (mostly comes from randomly letting the same thing come twice, multiple consecutive plosives, and multiple consecutive affricates.)


	# Create a list of vocabulary, including word-complexity (how long it should be), possible points on the animacy hierarchy, derivational possibilities
	



# https://en.wikipedia.org/wiki/Swadesh_list

# Base-system and stacking for numbers (English-like, Chinese-like, French-like, Nahuatl-like, etc)
	return conlangLexicon
end
# 13921721610493449161 - heavy rounding, good example syllables in CCCVC, 7286316329903538412 17563550202547560516 9209102147308907264
# 16576141541274087260 "rule" => "ɖodzuaɡʰa"

function deriveTerm(rng, phonology, phonotactics, complexity, derivations, derivationchance)
	# Must generate terms in order of how they might be derived, or else this won't work or will have to queue things for later.
	term = ""
	length = ceil(complexity/maximum(phonotactics) * 4rand(rng) + 0.001)
	for i in 1:length
		term *= generateSyllable(rng, phonology, phonotactics, complexity)
	end
	return term
end
function generateSyllable(rng, phonology, phonotactics, complexity)
	syllable = ""
	#for space in 1:phonotactics[1]
		#syllable *= rand(rng) < 0.9/space ? getCharAndDiacritics(rand(rng, phonology.consonants)) : ""
	#end
	onset = generateConsonantCluster(rng, phonology, phonotactics[1], complexity)
	println(onset)
	syllable *= join([getCharAndDiacritics(c) for c in onset])
	syllable *= rand(rng, getCharAndDiacritics(rand(rng, phonology.vowels))) #FIXME: Update getCharAndDiacritics for vowels.
	if phonotactics[2] > 0
	syllable *= join([getCharAndDiacritics(c) for c in generateConsonantCluster(rng, phonology, phonotactics[2], complexity)])
	end
	return syllable
end # FIXME: Complexity currently created 4453869935803909477: "exist " => kʰojdutsʰɹutsʰkxʰip" (Lang also has tʰ d + s z => tsʰ)
# "notify " => "bʰotsʰtʰitsʰ" 

#FIXME: Give phonemes a random weight determined by how easy they are to produce that will determine how common they are in words.
#TODO: Add an extra feature that limits certain types of clusters in a language and filters consonant cluster generation
function generateConsonantCluster(rng, phonology, max::Int, complexity::Int) 
	cluster = []
	# Don't repeat a sound twice. Don't go from a nasal to a nasal or a plosive to a plosive. Treat nonpulmonics like plosives.
	# Clicks can be followed by plosives but not preceeded. 
	# Nasals can only go to or come from a sound in the same position. Plosives have 1 degree of positional freedom.
	# Fricatives and liquids can go to or from anywhere
	#len = (rand(rng)^4 * max)# / (6/complexity+1) Complexity determines word length, not just syllable complexity
	len = sum([rand(rng) < 0.5 for i in 1:max])
	if len == 0; if rand(rng) < 0.9; len = 1; end; end
	#TODO: Incorporate complexity, so the simplest words (0) have minimal length.
	offset = 0 # Error-catching value for phoneme choices that have no legal next options. 
	for l in 1:len
		possiblePhonemes = copy(phonology.consonants)
		if length(cluster) > 0
			prev = cluster[l-1-offset]
			if lowercase(prev.manner) == "plosive" # No two stops in a row
				filter!((x) -> !(lowercase(x.manner) == "plosive" || nonpulmonic(x)), possiblePhonemes)
			elseif nonpulmonic(prev) && !(occursin("fricative", lowercase(prev.manner))) # No stops after a nonpulmonic, unless fricative
				filter!((x) -> !(lowercase(x.manner) == "plosive" || nonpulmonic(x)), possiblePhonemes)
			#elseif lowercase(prev.manner) == "nasal"
			#	filter!((x) -> (x.place == prev.place), possiblePhonemes)
			end
			filter!((x) ->!(x.place == prev.place && x.manner == prev.manner), possiblePhonemes) # No direct repeats, regardless of voicing/diacritics
		end
		if !isempty(possiblePhonemes)
		push!(cluster, rand(rng, possiblePhonemes))  
		else
		offset += 1 # fixes the l-1 case when a phoneme has no following options
		end
	end
	return cluster # 6604716746081193435 makes laɾɾzn wilnnn wɔnwww wawzsz; modified, good result: "ɣɔt'swŋ"
end

function vocabParser(rng, raw)
	data = split(raw, " ")
	words = []
	currentword = ""
	for d in data
		randval = rand(rng)
		if isequal(d, "/") || (isequal(d, "|") && randval>0.66) || (isequal(d, "!") && randval>0.33)
			currentword *= ", "
		elseif isequal(d, "\\") || isequal(d, "|") || isequal(d, "!")
			push!(words, currentword)
			currentword = ""
		else
			currentword *= d * " "
		end
	end
	push!(words, currentword)
	return words # [raw] for base dictionary 
end

function fixGenderToConlang(rng, gender) # TODO: Pull from grammar to query whether gender exists, which forms, and what to use for this word.
	return gender
end

# Vocab markup: 
# Word, complexity, base part of speech options, derivation parts of speech and english translation (Speak -> statement), animacy range/type of thing (if noun), transitivity (if verb)
# If property (i. e. allow there to be two posession words, one for living things one for inanimate things (find animacy values))
# Vocab splitup points marked with | or ! for potential splits and big ones (to determine whether things like say, tell, speak, state, recite should be split)
# 500-1000 words (enough for a basic set), organize synonyms
# USE SETS
# Type tree of parts of speech - Verbs: transitive, intransitive, and dative ; Nouns

# ?cut out of, cut (from), remove - ? means optional word
# Particles? Should be in morphology, theoretically.
#=
word()
=#

# Animacy:
# 1: people
# 2: children
# 3: strong animals / smart animals
# 4: weak / simple animals
# 5: Natural forces
# 6: inanimate objects
# 7: abstractions 

#= VOCABLIST FORMATTING
Prepositions
PoS, complexity, "trans | lations", "deriv-ation-s | ?", derivationchance
Nouns
PoS, complexity, "trans | lations", "deriv-ation-s", derivationchance, animacy, gender
Verbs
PoS, complexity, "trans | lations", "deriv-ation-s", derivationchance, transitivity
Adjectives 
PoS, complexity, "trans | lations", "nominal derivations", "verbal derivations", derivationchance
Adverbs
Possibly just derive automatically from Adjectives (things like bigly/greatly as intensifiers), then make a few specific ones

Translations: / - do not split, | - sometimes split, ! - often split, \ - always split

Conjunctions
PoS, complexity, "trans | lations"

Complexity: 0->, governs word length in a range of syllable counts from smallest to longest.
derivationchance: 0-5, with multiplied by a 20% chance for any of the derivations to be used.

Pronouns (reflexive, interrogative, etc.), grammaticalized terms, etc. get their own sections in the grammar.
=#