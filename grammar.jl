function buildGrammaticalSystem(seed) #buildPhraseStructure, really
	rng = MersenneTwister(seed)
	#create syntax structure, available cases, adpositions, how to use unavailable ones, etc.
	# Use Hawkins' Universals for adposition ordering influence on phrase structure (rather than simple head directionality)
	# Prep ⊃ ((NDem ∨ NNum ∨ NPos ⊃ NAdj) & (NAdj ⊃ NGen) & (NGen ⊃ NRel))
	# Posp ⊃ ((AdjN ∨ RelN ⊃ DemN & NumN & PossN) & (DemN ∨ NumN ∨ PossN ⊃ GenN))
	# Greenberg's Universalts for other, including SOV vs VSO influence on adpositionality
	
	# WORD ORDER
	#https://en.wikipedia.org/wiki/Word_order#
	randval = rand(rng)
	wordorderoptions = ["SOV", "SVO", "VSO", "VOS", "OVS", "OSV", "UNFIXED"]
	primaryWordOrder = wordorderoptions[
		findfirst(cumsum([0.405, 0.354, 0.069, 0.021, 0.007, 0.003, 0.141]) .> rand(rng))] #FIXME: Probability Citation needed (Left in data.jl)

	#head initial or head final (just do prepositional or postpositional)
	#SOV and VSO languages tend to specifically be one or the other, according to Artifexian 6:20. Find stats on that https://en.wikipedia.org/wiki/Greenberg%27s_linguistic_universals
	


	wordOrder = ["Subj", "Adj"]
	nounPhraseOrder = []
	verbPhraseOrder = []
	adposPhraseOrder = []
	# ALIGNMENT
	alignment = "Austronesian"

	return Grammar(primaryWordOrder, wordOrder, alignment)
end

function buildMorphology(seed)
	#assigns phonemes to grammatical system, pre/post placements, and (crucially) derivational morphology

	

end


# Select word order: Demonstrative first, Number first, Possessive first, then use that to influence the rest
# Grammatical cases -> Case hierarchy for marking
# 