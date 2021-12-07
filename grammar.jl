function buildGrammaticalSystem(seed) #buildPhraseStructure, really
	rng = MersenneTwister(seed)
	#create syntax structure, available cases, adpositions, how to use unavailable ones, etc.
	
	# WORD ORDER

	#https://en.wikipedia.org/wiki/Word_order#
	randval = rand(rng)
	wordorderoptions = ["SOV", "SVO", "VSO", "VOS", "OVS", "OSV", "UNFIXED"]
	primaryWordOrder = wordorderoptions[
		findfirst(cumsum([0.405, 0.354, 0.069, 0.021, 0.007, 0.003, 0.141]) .> rand(rng))] #FIXME: Probability Citation needed (Left in data.jl)


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
	
	# Hawkin's Universals for phrase structure
	nounPhraseStructure = [N]
	
	if prepositional
		# Prep ⊃ ((NDem ∨ NNum ∨ NPos ⊃ NAdj) & (NAdj ⊃ NGen) & (NGen ⊃ NRel))
		rand(rng) < 0.6 ? push!(nounPhraseStructure, DEM) : pushfirst!(nounPhraseStructure, DEM)
		phraseStructureInsert!(rng, nounPhraseStructure, rand(rng) < 0.6, NUM)
		phraseStructureInsert!(rng, nounPhraseStructure, rand(rng) < 0.6, POS)
		if comesbefore(nounPhraseStructure, N, DEM) || comesbefore(nounPhraseStructure, N, NUM) || comesbefore(nounPhraseStructure, N, POS)
			adjfirst = false
		else 
			adjfirst = rand(rng) < 0.6
		end
		if !adjfirst 
			phraseStructureInsert!(rng, nounPhraseStructure, true, GEN)
		else 
			phraseStructureInsert!(rng, nounPhraseStructure, rand(rng) < 0.6, GEN)
		end
		insert!(nounPhraseStructure, indexof(nounPhraseStructure, N)+1-adjfirst, ADJ) # Adjective stays close in constituent hierarchy of NP
		if comesbefore(nounPhraseStructure, N, GEN) 
			push!(nounPhraseStructure, REL)
		else 
			rand(rng) < 0.6 ? push!(nounPhraseStructure, REL) : pushfirst!(nounPhraseStructure, REL)
		end	

	else
		# Posp ⊃ ((AdjN ∨ RelN ⊃ DemN & NumN & PossN) & (DemN ∨ NumN ∨ PossN ⊃ GenN))
		relfirst = rand(rng) < 0.6
		adjfirst = rand(rng) < 0.6
		if adjfirst || relfirst
			phraseStructureInsert!(rng, nounPhraseStructure, false, DEM)
			phraseStructureInsert!(rng, nounPhraseStructure, false, NUM)
			phraseStructureInsert!(rng, nounPhraseStructure, false, POS)
		else
			phraseStructureInsert!(rng, nounPhraseStructure, rand(rng) < 0.4, DEM)
			phraseStructureInsert!(rng, nounPhraseStructure, rand(rng) < 0.4, NUM)
			phraseStructureInsert!(rng, nounPhraseStructure, rand(rng) < 0.4, POS)
		end
		if comesbefore(nounPhraseStructure, DEM, N) || comesbefore(nounPhraseStructure, NUM, N) || comesbefore(nounPhraseStructure, POS, N)
			phraseStructureInsert!(rng, nounPhraseStructure, false, GEN)
		else
			phraseStructureInsert!(rng, nounPhraseStructure, rand(rng) < 0.4, GEN)
		end
		insert!(nounPhraseStructure, indexof(nounPhraseStructure, N)+1-adjfirst, ADJ)
		relfirst ? pushfirst!(nounPhraseStructure, REL) : push!(nounPhraseStructure, REL)
	end # ["Relative", "Possessive", "Genitive", "Number", "Demonstrative", "Adjective", "Noun"] who I saw his 5 this hatted man 3189368585
	
	
	#[Dem Num Pos Gen Adj N Rel]


	verbPhraseOrder = []
	adposPhraseOrder = []
	# ALIGNMENT
	alignment = "Austronesian"

	# adpositional coverbs as per Theinar/Chinese
	
	# Adjective agreement and attributative verbs 
	# https://en.wikipedia.org/wiki/Attributive_verb#:~:text=An%20example%20of%20a%20verbal,attributive%20adjective%20in%20modifying%20man).

	return Grammar(primaryWordOrder, nounPhraseStructure, alignment)
end
function twoOf()
"""
Randomizes ordering of certain items in a phrase
"""
function randPhraseStructureInsert!(rng, phrase::Array, side::Bool, item) 
	center = indexof(phrase, N) # True side is right, false is left
	position = side ? rand(rng, center+1:length(phrase)+1) : rand(rng, 1:center)
	insert!(phrase, position, item)
end

function insertAround(phrase, anchor, items::Array{Tuple{Bool, Any}})
	center = indexof(phrase, anchor)
end

function comesbefore(array, i1, i2)
	return indexof(array, i1) < indexof(array, i2)
end

function indexof(A::Array, element)
	findnext(x -> x == element, A, 1)
end

function buildMorphology(seed)
	#assigns phonemes to grammatical system, pre/post placements, and (crucially) derivational morphology

	# Methods of Nominal Pluralization https://wals.info/chapter/33
	

end


# Select word order: Demonstrative first, Number first, Possessive first, then use that to influence the rest
# Grammatical cases -> Case hierarchy for marking
# 