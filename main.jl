using Random
include("data.jl") 
include("consonants.jl")
include("vowels.jl")
include("phonotactics.jl")
include("grammar.jl")
include("lexicon.jl")
include("output.jl")


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
	phonotactics = buildPhonotactics(seed)
	conlangGrammar = buildGrammaticalSystem(seed)
	println(conlangGrammar)
	conlangLexicon = buildLexemes(seed, phoneticInventory, phonotactics)
	println(conlangLexicon)
	conlangDict = Dict()
	for word in conlangLexicon
		conlangDict[word.translation] = word.word
	end
	@info conlangDict
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
		seed = rand(UInt64) # Sets a default seed in case people use "save" before running. 
		input = readline(stdin)
		inputs = split(input)
		if length(inputs) > 0
			if input == "reload" || input == "run" || input == "r"
				seed = rand(UInt64)
				constructLanguage(seed)
			elseif inputs[1] == "load" || inputs[1] == "l"
				if length(inputs) == 2
					seed = parse(UInt64, inputs[2])
					constructLanguage(seed)
				end
			elseif inputs[1] == "save" || inputs[1] == "s"
				if length(inputs) == 2
					seed = parse(UInt64, inputs[2])
					exportLanguage(seed)
				else
					exportLanguage(seed)
				end
			elseif input == "exit" || input == "quit" || input == "q"
				break
			end 
		end
	end
end

main()


