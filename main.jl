using Random
include("data.jl") #(Datastructure to query how everything relates to one another. if all else fails, do popping from a set and rejecting probablistically)
include("consonants.jl")
include("vowels.jl")
include("phonotactics.jl")
include("grammar.jl")
include("lexicon.jl")


function buildPhoneticInventory(seed) 
	consonantInventory = buildConsonantInventory(seed)
	vowelInventory = buildVowelInventory(seed)
	return IPAphoneticInventory(consonantInventory, vowelInventory)
end

function constructLanguage(seed)
	@info seed
	phoneticInventory = buildPhoneticInventory(seed)
	@info phoneticInventory
	phonemearray = []
	for p in phoneticInventory.consonants
		push!(phonemearray, getCharAndDiacritics(p))
	end
	for p in phoneticInventory.vowels
		push!(phonemearray, p.phoneme)
	end
	println(phonemearray)
	conlangGrammar = buildGrammaticalSystem(seed)
	println(conlangGrammar)
end

function main()
	#Data.initializeData()
	#constructLanguage()
	println("Commands:")
	println("r, run, reload - create and display language")
	println("l, load <seed> - load language with seed (ex. load 72548917)")
	println("s, save - save current language as a markdown file")
	println("q, quit, exit - exit")
	while true # DO WHILE?
		input = readline(stdin)
		inputs = split(input)
		if inputs == "reload" || input == "run" || input == "r"
			seed = Int(trunc(rand()*(10^10)))
			constructLanguage(seed)
		elseif inputs[1] == "load" || inputs[1] == "l"
			if length(inputs) == 2
				seed = parse(Int, inputs[2])
				constructLanguage(seed)
			end
 		elseif input == "save" || input == "s"
			nothing
		elseif input == "exit" || input == "quit" || input == "q"
			break
		end 
	end
end

main()

# Storing too much in the ipaconsonant, probably don't do

# TODO: Explain the process in the comments to describe what the code is doing.
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

