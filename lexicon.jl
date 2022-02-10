function buildLexemes(seed, phonolgy::IPAphoneticInventory, phonotactics)
	rng = MersenneTwister(seed)
	#creates the broader units of meaning, then builds words
	#define words with type and definition, possibly include way for overlap
	onset = phonotactics[1]
	coda = phonotactics[2]

	println("Reading Dictionary...")
	vocabList = CSV.read("vocablist.csv", DataFrame)
	conlangLexicon = []
	for i in 1:size(vocabList)[1] 
		if vocabList[i, 1] == "noun"
			rawTranslation = vocabList[i, 3]
			definitions = vocabParser(rng, rawTranslation)
			for d in definitions
				conword = deriveTerm(rng, phonolgy, phonotactics, vocabList[i, 2], vocabList[i, 4], vocabList[i, 5])
				gender = fixGenderToConlang(rng, vocabList[i, 7])
				push!(conlangLexicon, Noun(d, conword, gender, vocabList[i, 6]))
			end
		elseif vocabList[i, 1] == "verb"
			rawTranslation = vocabList[i, 3]
			definitions = vocabParser(rng, rawTranslation)
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
		end
	end # Good lexical generation: qχots, pɸɑf, npɶnts
	# Bad lexical generation: kxqχøk, χχʂɐx, kxkxʌsf, qχpɸɳɶtp 
	# (mostly comes from randomly letting the same thing come twice, multiple consecutive plosives, and multiple consecutive affricates.)
	println(conlangLexicon)


	# Create a list of vocabulary, including word-complexity (how long it should be), possible points on the animacy hierarchy, derivational possibilities
	



# https://en.wikipedia.org/wiki/Swadesh_list

# Base-system and stacking for numbers (English-like, Chinese-like, French-like, Nahuatl-like, etc)

end

function deriveTerm(rng, phonology, phonotactics, complexity, derivations, derivationchance)
	# Must generate terms in order of how they might be derived, or else this won't work or will have to queue things for later.
	return generateSyllable(rng, phonology, phonotactics)
end
function generateSyllable(rng, phonology, phonotactics)
	syllable = ""
	for space in 1:phonotactics[1]
		syllable *= rand(rng) < 0.9/space ? getCharAndDiacritics(rand(rng, phonology.consonants)) : ""
	end
	syllable *= rand(rng, getCharAndDiacritics(rand(rng, phonology.vowels))) #FIXME: Update getCharAndDiacritics for vowels.
	if phonotactics[2] > 0
	for space in 1:phonotactics[2]
		syllable *= rand(rng) < 0.9/space ? getCharAndDiacritics(rand(rng, phonology.consonants)) : ""
	end
	end
	return syllable
end

function generateConsonantCluster(rng, phonology, phonotactics)
	cluster = []
	# Don't repeat a sound twice. Don't go from a nasal to a nasal or a plosive to a plosive. Treat nonpulmonics like plosives.
	# Clicks can be followed by plosives but not preceeded. 
	# Nasals can only go to or come from a sound in the same position. Plosives have 1 degree of positional freedom.
	# Fricatives and liquids can go to or from anywhere
	
end

function vocabParser(rng, raw)
	data = split(raw, " ")
	return raw
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