function buildGrammaticalSystem(seed) #buildPhraseStructure, really
	rng = MersenneTwister(seed)
	
	# WORD ORDER

	# Data taken from https://en.wikipedia.org/wiki/Word_order#Distribution_of_word_order_types Dryer 2005 Study
	wordorderoptions = ["SOV", "SVO", "VSO", "VOS", "OVS", "OSV", UNF]
	primaryWordOrder = wordorderoptions[
		findfirst(cumsum([0.405, 0.354, 0.069, 0.021, 0.007, 0.003, 0.141]) .> rand(rng))] 


	# NOUN PHRASE STRUCTURE

	#https://en.wikipedia.org/wiki/Greenberg%27s_linguistic_universals
	# https://wals.info/chapter/95 V/O languages tend to be prepositional, vice-versa for O/V
	if primaryWordOrder == "SVO" || primaryWordOrder == "VSO" || primaryWordOrder == "VOS" 
		prepositional = rand(rng) < 0.915
	elseif primaryWordOrder == "SOV" || primaryWordOrder == "OVS" || primaryWordOrder == "OSV"
		prepositional = rand(rng) < 0.029
	else # Unfixed languages
		prepositional = rand(rng) < 0.65
	end
	# Generalize Head-directionality parameter from Universals and clause order
	
	nounPhraseStructure = [N]
	# Using Hawkin's Universals for phrase structure
	if prepositional
		# Prep ⊃ ((NDem ∨ NNum ∨ NPos ⊃ NAdj) & (NAdj ⊃ NGen) & (NGen ⊃ NRel))
		demfirst = rand(rng) < 0.4
		posfirst = rand(rng) < 0.4
		numfirst = rand(rng) < 0.4
		if !demfirst || !posfirst || !numfirst
			adjfirst = false
		else 
			adjfirst = rand(rng) < 0.4
		end
		if !adjfirst 
			genfirst = false
		else 
			genfirst = rand(rng) < 0.4
		end
		if !genfirst
			relfirst = false
		else 
			relfirst = rand(rng) < 0.6 
		end	
	else
		# Posp ⊃ ((AdjN ∨ RelN ⊃ DemN & NumN & PossN) & (DemN ∨ NumN ∨ PossN ⊃ GenN))
		relfirst = rand(rng) < 0.6
		adjfirst = rand(rng) < 0.6
		if adjfirst || relfirst
			demfirst = true
			posfirst = true
			numfirst = true
		else
			demfirst = rand(rng) < 0.6
			posfirst = rand(rng) < 0.6
			numfirst = rand(rng) < 0.6
		end
		if demfirst || posfirst || numfirst
			genfirst = true
		else
			genfirst = rand(rng) < 0.6
		end

	end
	# Greenberg Universal 20: 
	# Order must be DEM NUM ADJ N, N DEM NUM ADJ, or N ADJ NUM DEM with REL at either extremity
	if twoOf((!demfirst || !posfirst || !genfirst), !numfirst, !adjfirst) && rand(rng) < 0.2
		insertAround(nounPhraseStructure, N, # N DEM NUM ADJ case; the first things will be the furthest out
			[(adjfirst, ADJ), (numfirst, NUM), (genfirst, GEN), (posfirst, POS), (demfirst, DEM)])
	else
		insertAround(nounPhraseStructure, N, 
			[(demfirst, DEM), (posfirst, POS), (genfirst, GEN), (numfirst, NUM), (adjfirst, ADJ)])
	end
	prepositional ? pushfirst!(nounPhraseStructure, ADP) : push!(nounPhraseStructure, ADP) # FIXME: could be marked internally, directly affixed on the noun - handle in Morphology
	relfirst ? pushfirst!(nounPhraseStructure, REL) : push!(nounPhraseStructure, REL)

	@info prepositional 

	# Where does the PP go around the NP? Not necessarily with adjectives or relative clauses; it's another one not listed.
	
	verbPhraseStructure = []
	if primaryWordOrder != UNF
		adpfirst = rand(rng) < 0.9 ? adjfirst : !adjfirst
		@info primaryWordOrder
		for p in primaryWordOrder
			if p == 'V'# 6179186629
				push!(verbPhraseStructure, V)
			elseif p == 'S'
				push!(verbPhraseStructure, SUB)
			elseif p == 'O'
				push!(verbPhraseStructure, OBJ)
			end
		end
		insert!(verbPhraseStructure, indexof(verbPhraseStructure, SUB)+1-adpfirst, PPhrase)
		insert!(verbPhraseStructure, indexof(verbPhraseStructure, OBJ)+1-(rand(rng)<0.5), INDOBJ)
	else
		verbPhraseStructure = [UNF] # Mark with declension in unfixed case
	end

	adposPhraseOrder = [] # handled in NP order. Real question is where ADPPs go with respect to NP.

	# MORPHOSYNTACTIC ALIGNMENT https://wals.info/chapter/98
	alignmentoptions = [NOMACC, NOMMAR, ERGABS, TRIPAR, ACTSTA, DIRECT]
	if primaryWordOrder != UNF 
		alignment = alignmentoptions[
			findfirst(cumsum([0.21, 0.03, 0.14, 0.02, 0.02, 0.58]) .> rand(rng))] 
	else
		alignment = alignmentoptions[
			findfirst(cumsum([0.48, 0.05, 0.34, 0.06, 0.07]) .> rand(rng))] 
	end
	
	#TODO: Pronoun-only alignment in Morphology

	

	# adposition-derived grammatical coverbs as per Theinar/Chinese



	# Adjective agreement and attributative verbs 
	# https://en.wikipedia.org/wiki/Attributive_verb#:~:text=An%20example%20of%20a%20verbal,attributive%20adjective%20in%20modifying%20man).
	# https://wals.info/chapter/118
	predicativeAdjectiveEncoding = (rand(rng) < 0.4) + rand(rng) < 0.4 # 0: Verbal, 1: Nominal, 2: Mixed

	return Grammar(	primaryWordOrder, 
					nounPhraseStructure, 
					verbPhraseStructure, 
					prepositional, 
					alignment, 
					predicativeAdjectiveEncoding)
end 
function twoOf(b1::Bool, b2::Bool, b3::Bool)
	return (b1 && b2) || (b2 && b3) || (b1 && b3)
end
"""
Randomizes ordering of certain items in a phrase
"""
function randPhraseStructureInsert!(rng, phrase::Array, side::Bool, item) 
	center = indexof(phrase, N) # True side is right, false is left
	position = side ? rand(rng, center+1:length(phrase)+1) : rand(rng, 1:center)
	insert!(phrase, position, item)
end
"""
Inserts a list of items in order around an anchor position, which is taken as the first index of the anchor element.
Items are stored in an array of tuples, with the first index determining if they go after anchor (false), or before the 
anchor (true).
"""
function insertAround(phrase::Array, anchor, items::Vector{Tuple{Bool, String}})
	for item in items
		center = indexof(phrase, anchor)
		insert!(phrase, center+1-item[1], item[2])
	end
end

function comesbefore(array, i1, i2)
	return indexof(array, i1) < indexof(array, i2)
end

function indexof(A::Array, element)
	findnext(x -> x == element, A, 1)
end
     
function buildMorphology(seed, grammar::Grammar)
	rng = MersenneTwister(seed)
	#assigns phonemes to grammatical system, pre/post placements, and (crucially) derivational morphology

	# Methods of Nominal Pluralization https://wals.info/chapter/33
	
	# Pronoun-only gender
	# Lexical gender
	# Animate/Inanimate
	# Animacy hierarchy
	#Phonetic Noun Class (endings or beginnings, by affix location, like Irkhilakhu)
	genderSystem = rand(rng)
	classes = []
	if genderSystem < 0.2 # No gender whatsoever
		classSystem = NounClassSystem(false, nothing)
	elseif genderSystem < 0.5 # Gender-gender with masc, fem, neuter
		classes = copy(genderClasses) # FIXME: copy so as to not mutate const
		del = rand(rng, 1:7) # 1-7
		if del < 4; popat!(classes, del); end # Remove one of the distinctions randomly
		classSystem = NounClassSystem(rand(rng) < 0.5,
						"Gender")
	elseif genderSystem < 0.7 # Animate/inanimate gender
		classes = ["Animate", "Inanimate"] # Or Human/Nonhuman
		classSystem = NounClassSystem(rand(rng) < 0.5,
						"Animacy")
	elseif genderSystem < 0.9 # Animacy hierarchy system

		classSystem = NounClassSystem(rand(rng) < 0.5,
						"Animacy Hierarchy")
	else # Swahili-like Derivational Noun Class
		
		classSystem = NounClassSystem(false, "Derivational Class")
	end
	# In no-gender languages, perhaps allow for a Chinese-esque classing by count modifier
	

	# Pronoun-only gender (actual gender or animacy, or both as in English)
	


	# CASES/ALIGNMENT
	cases = []
	if grammar.alignment == ERGABS
		push!(cases, "Ergative")
		push!(cases, "Absolutive")
	end



	# Pronoun-only alignment

	# Converbs


	# Associated Motion
	# do&go vs go&do vs go (to) do - & implies it was done
	# Vocative 



end

function buildGrammaticalMarkings(seed, phonlogy)
	rng = MersenneTwister(seed)
	return GrammarTable()
end


# Grammatical cases -> Case hierarchy for marking
# 