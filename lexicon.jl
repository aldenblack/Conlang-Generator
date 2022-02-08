function buildLexemes(seed, phonolgy::IPAphoneticInventory, phonotactics)
	#creates the broader units of meaning, then builds words
	#define words with type and definition, possibly include way for overlap
	onset = phonotactics[1]
	coda = phonotactics[2]

	println("Reading Dictionary...")
	vocabList = CSV.read("vocablist.csv", DataFrame)
	conlangLexicon = []
	for i in 1:size(vocabList)[1] # 1-2000
		if vocabList[i, 1] == "noun"
			push!(conlangLexicon, Noun(vocabList[i, 3], deriveTerm(vocabList[i, 2], vocabList[i, 4], vocabList[i, 5]), gender, vocabList[i, 6]))
		end
	end


	# Create a list of vocabulary, including word-complexity (how long it should be), possible points on the animacy hierarchy, derivational possibilities
	



# https://en.wikipedia.org/wiki/Swadesh_list

# Base-system and stacking for numbers (English-like, Chinese-like, French-like, Nahuatl-like, etc)

end

function deriveTerm(complexity, derivations, derivationchance)
	# Need to generate terms in order of how they might be derived, or else this won't work or will have to queue things for later.
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
PoS, complexity, "trans | lations", "deri-vation-s | ?", derivationchance
Nouns
PoS, complexity, "trans | lations", "deri-vation-s", derivationchance, animacy
Verbs
PoS, complexity, "trans | lations", "deri-vation-s", derivationchance, transitivity
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