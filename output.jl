# Exports a language sketch into a readable markdown format

# PHONOLOGY 



# GRAMMAR 
# Noun Phrase order indicates where words that modify a noun should go. Not all will be present in a given phrase.
# (Examples of certain phrases in English and conlang, to show all PoSs)
# Nominative is the subject of a transitive or intransitive verb ()
# Accusative is the object of a transitive verb ()
# Ergative is the subject of a transitive verb ()
# Absolutive is the subject of an intransitive verb () or the object of a transitive verb ()


# LEXICON 


function exportLanguage(seed)
    println(seed)

    phoneticInventory = buildPhoneticInventory(seed)
    #consonantInventory = zeros(String, 8, 11) #zeros(IPAconsonant, 8, 11)
    #for consonant in phoneticInventory.consonants
        #consonantInventory[ eval(Meta.parse(uppercase(consonant.place))), 
        #                    eval(Meta.parse(uppercase(consonant.manner)))] = getCharAndDiacritics(consonant)
    #end
    places = []
    manners = []
    for consonant in phoneticInventory.consonants
        if !(consonant.manner in manners)
            push!(manners, consonant.manner)
        end
        if !(consonant.place in places)
            push!(places, consonant.place)
        end
    end
    consonantInventory = zeros(String, length(manners), length(places)) # confirm this order
    for consonant in phoneticInventory.consonants
        consonantInventory[ indexof(manners, consonant.manner), 
                            indexof(places, consonant.place)] *= getCharAndDiacritics(consonant) * " "
    end
    println(consonantInventory)
    # No AFFRICATE (s 7752888951)

    # Have output be sent to standard out, then use > in shell to write to a new file


end


#function zeros(::Line, dims)
#    a = Array{IPAconsonant}(undef, 2, 2)
#    for i in dims
#        a[i] = IPAconsonant("", "", "", false, IPAdiacritic[])
#    end
#    a
#end
