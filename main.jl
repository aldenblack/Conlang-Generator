using Random
include("data.jl") 
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


