# Exports a language sketch into a readable markdown format

# PHONOLOGY 
function formatConsonants

end

function formatVowels

end


# GRAMMAR 
# Noun Phrase order indicates where words that modify a noun should go. Not all will be present in a given phrase.
# (Examples of certain phrases in English and conlang, to show all PoSs)
# Nominative is the subject of a transitive or intransitive verb ()
# Accusative is the object of a transitive verb ()
# Ergative is the subject of a transitive verb ()
# Absolutive is the subject of an intransitive verb () or the object of a transitive verb ()


# LEXICON 



# EXPORT


function exportLanguage(seed)
    println(seed)

    phoneticInventory = buildPhoneticInventory(seed)
    #=consonantInventory = zeros(String, 8, 11) #zeros(IPAconsonant, 8, 11)
    for consonant in phoneticInventory.consonants
        consonantInventory[ eval(Meta.parse(uppercase(consonant.place))), 
                            eval(Meta.parse(uppercase(consonant.manner)))] = getCharAndDiacritics(consonant)
    end=#
    places = []
    manners = []
    for consonant in phoneticInventory.consonants
        if !(consonant.manner in manners)
            push!(manners, consonant.manner)
        end 
        if !(consonant.place in places)
            if consonant.place != "Labiovelar" # Handles the w case
                push!(places, consonant.place)
            end
        end  
    end
    sort!(manners, by = x -> eval(Meta.parse(uppercase(filter(y -> !isspace(y),x)))))
    sort!(places, by = x -> eval(Meta.parse(uppercase(filter(y -> !isspace(y),x)))))
    consonantInventory = zeros(String, length(manners), length(places)) # confirm this order
    
    for consonant in phoneticInventory.consonants
        consonantInventory[ indexof(manners, consonant.manner), 
                            indexof(places, consonant.place)] *= getCharAndDiacritics(consonant) * " "
    end
    println(consonantInventory)
    # No AFFRICATE (s 7752888951) 12402786302224154849 11431623570435205651 14943285023183830847
    # 2nd seed- exist => ɴupʰɣavɽuɢʁsiⁿɢ (exist's complexity is too high, as is only, state, rule, express/define(etc)), "live " => "jiⁿbtsaⁿdzɢʁev
    # dʰeⁿdzⁿdziɡɣʰsuqʰsoⁿdz tuuχⁿdzoⁿdz (is 3 of the same vowel in a row possible?) rule χuqʰmostiɴŋozvu (ɴŋ shouldn't exist)
    # kanldlɑβz dɶdzɗl jɶɗjz nzɤɓβlɤβɓrɜj

    # Markdown formatting 
    consonantChart = "| | " * prod([place * " | " for place in places]) * "\n|" * "---|"^(length(places)+1) 
    for row in 1:(length(manners))
        consonantChart *= "\n| **" * manners[row] * "** |"
        for column in 1:length(places)
            consonantChart *= " " * consonantInventory[row, column] * "|"
        end
    end
    println(consonantChart)
    # Have output be sent to standard out, then use > in shell to write to a new file

    # VOWELS

    heights = []
    backnesses = []
    for vowel in phoneticInventory.vowels
        if !(vowel.height in heights)
            push!(heights, vowel.height)
        end 
        if !(vowel.backness in backnesses)
            push!(backnesses, vowel.backness)
        end  
    end
    sort!(heights, by = x -> eval(Meta.parse(uppercase(filter(y -> !isspace(y),x)))))
    sort!(backnesses, by = x -> eval(Meta.parse(uppercase(filter(y -> !isspace(y),x)))))
    vowelInventory = zeros(String, length(manners), length(places))
    for vowel in phoneticInventory.vowels
        vowelInventory[ indexof(heights, vowel.height), 
                            indexof(backnesses, vowel.backness)] *= getCharAndDiacritics(vowel) * " "
    end
    println(vowelInventory)
    # FIXME: Filter -, then change closemid to Close-mid and capitalize all.

    # Markdown formatting 
    vowelChart = "| | " * prod([backness * " | " for backness in backnesses]) * "\n|" * "---|"^(length(backnesses)+1) 
    for row in 1:(length(heights))
        vowelChart *= "\n| **" * heights[row] * "** |"
        for column in 1:length(backnesses)
            vowelChart *= " " * vowelInventory[row, column] * "|"
        end
    end
    println(vowelChart)

    #GRAMMAR

    grammar = buildGrammaticalSystem(seed)

    languagename = "LANG"
    #=struct Grammar
        mainWordOrder::String
        NPStructure::Array{String}
        VPStructure::Array{String}
        prepositions::Bool
        alignment::String
        adjEncoding::Int
    end=#

    if grammar.mainWordOrder != UNF
        iseeitExample = reorderPhrase(Root(VP("see", NP("it", nothing)), NP("I", nothing)), grammar)
        safegrammar = grammar
        println(languagename * " has a(n) " * grammar.mainWordOrder * " (" * eval(Meta.parse(grammar.mainWordOrder)) * ") word order. For instance, the phrase \"I see it\" would be reordered to become \"" * iseeitExample * "\"")
    else # UNFIXED EXAMPLE: 2528772731991799506
        safegrammar = Grammar("SOV", grammar.NPStructure, ["Prepositional Phrase", "Subject", "Indirect Object", "Direct Object", "Verb"], grammar.prepositions, grammar.alignment, grammar.adjEncoding) # FIXME: Make this a bit more natural to the unfixed language. 
        # ^ Default parameters for an unfixed language
        println(languagename * " has an unfixed word order. For instance, the phrase \"I see it\" could be said in any permutation, including \"see it I\" and \"I it see.\"")
    end
    println("\n\nNoun phrases have a basic order of:")
    println(grammar.NPStructure)
    println("\n\nVerb phrases have a basic order of:")
    println(grammar.VPStructure)
    println("Key: ")
    dogExample = Root(VP(VP("drops", NP(NP("hat", DP("his", "GEN", nothing)), PP("on", NP("ground", DP("the", "DET", nothing))))), MP("clumsily", nothing)), NP(NP("dog", DP("big", "ADJ", DP("the", "DET", nothing))), RP("who", Root(VP("know", nothing), NP("I", nothing)))))
   # printPhraseStructure(dogExample)
    println("--------------")
    #printPhraseAlternate(dogExample)
    println("Example: The big dog who I know drops his hat on the ground clumsily. -> " * reorderPhrase(dogExample, safegrammar))


end

function reorderPhrase(phrase::Phrase, grammar::Grammar, result = [])
    reorderHelper(phrase, grammar, result) # Mutates result
    transliteration = ""
    for word in result
        transliteration *= word * " "
    end
    transliteration = uppercase(transliteration[1]) * transliteration[2:end-1] * "."
    return transliteration
end

function reorderHelper(phrase::Phrase, grammar::Grammar, result)
    reorderHelper(phrase.head, grammar, result)
    reorderHelper(phrase.dependent, grammar, result)
end
function reorderHelper(phrase::String, grammar::Grammar, result)
    push!(result, phrase)
end
function reorderHelper(phrase::Nothing, grammar::Grammar, result, DPsOrder=[])
    
end
function reorderHelper(phrase::Root, grammar::Grammar, result)
    # FIXME: May not support OSV (TEST) since verb will go after, then object before, resulting in SOV. 
    if findfirst('S', grammar.mainWordOrder) < findfirst('V', grammar.mainWordOrder)
        reorderHelper(phrase.dependent, grammar, result)
        reorderHelper(phrase.head, grammar, result)
    else
        reorderHelper(phrase.head, grammar, result)
        reorderHelper(phrase.dependent, grammar, result)
    end
end
function reorderHelper(phrase::VP, grammar::Grammar, result)
    if indexof(grammar.VPStructure, "Direct Object") < indexof(grammar.VPStructure, "Verb")
        reorderHelper(phrase.dependent, grammar, result)
        reorderHelper(phrase.head, grammar, result)
    else
        reorderHelper(phrase.head, grammar, result)
        reorderHelper(phrase.dependent, grammar, result)
    end
end

function reorderHelper(phrase::RP, grammar::Grammar, result)
    # FIXME: Rel marks where the relative *clause* goes, not the relative marker. RM should relate to RM structure and S-O-V order.
    if indexof(grammar.NPStructure, "Relative") > indexof(grammar.NPStructure, "Noun")
        reorderHelper(phrase.dependent, grammar, result)
        reorderHelper(phrase.head, grammar, result)
    else
        reorderHelper(phrase.head, grammar, result)
        reorderHelper(phrase.dependent, grammar, result)
    end
end

function reorderHelper(phrase::NP, grammar::Grammar, result, DPsOrder = [])
    if phrase.dependent isa DP #Intrinsically handles if head is NP vs String
        (phrase.head isa String) && push!(DPsOrder, (phrase.head, "Noun"))
        reorderHelper(phrase.dependent, grammar, result, DPsOrder)
        sort!(DPsOrder, by = x -> indexof(grammar.NPStructure, x[2]))
        append!(result, [word[1] for word in DPsOrder])
    elseif phrase.dependent isa PP
        if indexof(grammar.VPStructure, "Prepositional Phrase") > indexof(grammar.VPStructure, "Subject")
            reorderHelper(phrase.dependent, grammar, result)
            reorderHelper(phrase.head, grammar, result)
        else
            reorderHelper(phrase.head, grammar, result)
            reorderHelper(phrase.dependent, grammar, result)
        end
    elseif phrase.dependent isa RP # Marks relative clause position to noun, not RM position in phrase.
        if indexof(grammar.NPStructure, "Relative") > indexof(grammar.NPStructure, "Noun")
            reorderHelper(phrase.dependent, grammar, result)
            reorderHelper(phrase.head, grammar, result)
        else
            reorderHelper(phrase.head, grammar, result)
            reorderHelper(phrase.dependent, grammar, result)
        end
    else
        reorderHelper(phrase.head, grammar, result) # if dependent is nothing, send head here.
    end # if neither of these, dependent is nothing.
end

# Verbs, PPs/RPs, and MPs are all pushing properly. DPs and NPs are failing. 
function reorderHelper(phrase::DP, grammar::Grammar, result, DPsOrder)
    if phrase.dependent isa MP
        #FIXME: Adverbial/ITSFR/AUG direction indeterminate (currently always first) - and only one will be added to the whole DP at a time.
        reorderHelper(phrase.dependent, grammar, result, DPsOrder) #TODO: Let an arbitrary number of MPs append to a DP
    else
        reorderHelper(phrase.dependent, grammar, result, DPsOrder)
    end
    if phrase.head isa String
        push!(DPsOrder, (phrase.head, getDPPoS(phrase)))
    else
        reorderHelper(phrase.head, grammar, result, DPsOrder)
    end
end
function reorderHelper(phrase::MP, grammar::Grammar, result)
    #TODO: Edit functionality for DPs and verbs
    push!(result, phrase.head)
    reorderHelper(phrase.dependent, grammar, result)
end

function getDPPoS(phrase::DP) # Helper for DP reorderHelper, which allows the PoS marking to be interpreted.
    if uppercase(phrase.headPoS) == "DET"
        return "Demonstrative"
    elseif uppercase(phrase.headPoS) == "GEN"
        return "Genitive"
    elseif uppercase(phrase.headPoS) == "NUM"
        return "Number"
    elseif uppercase(phrase.headPoS) == "POS"
        return "Possessive"
    elseif uppercase(phrase.headPoS) == "ADJ"
        return "Adjective"
    end
end

function reorderPhraseIter(phrase::Phrase, wordOrder, NPorder, VPorder, adpOrder)
    wordOrderVal["S"]
    # Traverse the phrase structure down whichever phrase part comes first
    reordered = ""
    ordering = true
    # ["Prepositional Phrase", "Subject", "Indirect Object", "Direct Object", "Verb"]
    # ["Relative", "Demonstrative", "Possessive", "Genitive", "Number", "Adjective", "Noun", "Adposition"]
    # PP goes before NP, but ADP is a postposition.
    phraseSubset = phrase
    currentPhrase = ""
    while ordering 
        # Find earliest part of phrase
        # Remove it and append to reordered string

    end
    return currentPhrase
end

function findFirstPhrase(phrase, NPorder, VPorder, adpOrder)
    nextPhrase = Root("", nothing)
    firstPhrase = ""

    return firstPhrase, nextPhrase
end




#=function zeros(::Line, dims)
    a = Array{IPAconsonant}(undef, 2, 2)
    for i in dims
        a[i] = IPAconsonant("", "", "", false, IPAdiacritic[])
    end
    a
end=#

"Check whether a phrase branches or ends. Return true if the phrase ends."
function isleaf(phrase) 
	return isnothing(phrase.dependent)
end

"Print phrase structure tree."
function printPhraseStructure(phrase::Phrase, depth=0, head::Bool=true)  # Phrase-head collapsing causes display issues with multiple distinct phrases () ()
    if typeof(phrase) <: Phrase
		if typeof(phrase.head) <: String
			println("\t"^depth * phrase.head)
		elseif typeof(phrase.head) <: Phrase
			printPhraseStructure(phrase.head, depth+1, true) # Raises branching on both head and node
		end
		if head # put the branches out from the head of the phrase
			depth+=1
		end
		if !isleaf(phrase)
			printPhraseStructure(phrase.dependent, depth, false)
		end 
	end
end

function printPhraseAlternate(phrase::Phrase, depth=0)
	if typeof(phrase) <: Phrase
		if typeof(phrase.head) <: String
			println("\t"^depth * phrase.head)
		end
		if typeof(phrase.head) <: Phrase
			printPhraseAlternate(phrase.head, depth+1)
			println("\t"^depth * "---")
		end
		if !isleaf(phrase)
			printPhraseAlternate(phrase.dependent, depth)
		end 
	end
end
