#module Data
using CSV
using DataFrames


struct CSVconsonant
	phoneme::String
	frequency::Float64 # Between 0-1
end

CSVconsonants = []
function initializeData()
	# Phonology
	println("Initializing...")
	phonemeData = CSV.read("Parameters.csv", DataFrame)
	for i in 1:size(phonemeData)[1] # 1-2000
		if phonemeData[i, 10] == "consonant"
			push!(IPAconsonants, CSVconsonant(phonemeData[i, 2], phonemeData[i, 3]))
		end
	end
end

#end # End Module

IPApulmonicConsonants = [ # % - blank, * - grey
# Bilabial   Labiodental   Dental     Alveolar  Postalveolar  Retroflex   Palatal      Velar       Uvular    Pharyngeal   Glottal
[('%', 'm'), ('%', 'ɱ'), ('%', '%'), ('%', 'n'), ('%', '%'), ('%', 'ɳ'), ('%', 'ɲ'), ('%', 'ŋ'), ('%', 'ɴ'), ('*', '*'), ('*', '*')], # Nasal
[('p', 'b'), ('%', '%'), ('%', '%'), ('t', 'd'), ('%', '%'), ('ʈ', 'ɖ'), ('c', 'ɟ'), ('k', 'ɡ'), ('q', 'ɢ'), ('ʡ', '*'), ('ʔ', '*')], # Plosive
[('ɸ', 'β'), ('f', 'v'), ('θ', 'ð'), ('s', 'z'), ('ʃ', 'ʒ'), ('ʂ', 'ʐ'), ('ç', 'ʝ'), ('x', 'ɣ'), ('χ', 'ʁ'), ('ħ', 'ʕ'), ('h', 'ɦ')], # Fricative # ɕ ʑ palatal silibant fricatives
[('%', 'ʙ'), ('%', '%'), ('%', '%'), ('%', 'r'), ('%', '%'), ('%', '%'), ('%', '%'), ('*', '*'), ('%', 'ʀ'), ('%', '%'), ('*', '*')], # Trill
[('%', '%'), ('%', 'ⱱ'), ('%', '%'), ('%', 'ɾ'), ('%', '%'), ('%', 'ɽ'), ('%', '%'), ('*', '*'), ('%', '%'), ('%', '%'), ('*', '*')], # Tap or Flap
[('*', '*'), ('*', '*'), ('%', '%'), ('ɬ', 'ɮ'), ('%', '%'), ('%', '%'), ('%', '%'), ('%', '%'), ('%', '%'), ('*', '*'), ('*', '*')], # Lateral Fricative
[('%', '%'), ('%', 'ʋ'), ('%', '%'), ('%', 'ɹ'), ('%', '%'), ('%', 'ɻ'), ('%', 'j'), ('%', 'ɰ'), ('%', '%'), ('%', '%'), ('*', '*')], # Approximant
[('*', '*'), ('*', '*'), ('%', '%'), ('%', 'l'), ('%', '%'), ('%', 'ɭ'), ('%', 'ʎ'), ('%', 'ʟ'), ('%', '%'), ('*', '*'), ('*', '*')]  # Lateral Approximant
]
BILABIAL = 1
LABIODENTAL = 2
DENTAL = 3
ALVEOLAR = 4
POSTALVEOLAR = 5
RETROFLEX = 6
PALATAL = 7
VELAR = 8
UVULAR = 9
PHARYNGEAL = 10
GLOTTAL = 11
NASAL = 1
PLOSIVE = 2
FRICATIVE = 3
TRILL = 4
TAP = 5
LATERALFRICATIVE = 6
APPROXIMANT = 7
LATERALAPPROXIMANT = 8
pulmonicPlaces = Dict(
	1 => "Bilabial", 
	2 => "Labiodental",
	3 => "Dental",
	4 => "Alveolar",
	5 => "Postalveolar",
	6 => "Retroflex",
	7 => "Palatal",
	8 => "Velar",
	9 => "Uvular",
	10 => "Pharyngeal",
	11 => "Glottal"
	)
pulmonicManners = Dict(
	1 => "Nasal", 
	2 => "Plosive",
	3 => "Fricative",
	4 => "Trill",
	5 => "Tap",
	6 => "Lateral Fricative",
	7 => "Approximant",
	8 => "Lateral Approximant",
	9 => "Affricate"
	)

struct IPAdiacritic 
	diacritic::Char
	type::String
end

struct IPAconsonant # Pulmonic and nonpulmonic; click and voiced implosive are manner, ejectives how? 
	phoneme::Union{String, Char}
	place::String
	manner::String
	voice::Bool # May not be needed
	diacritics::Array{IPAdiacritic}
end

struct IPAvowelmodifier # Include tone, nasal, and length
	diacritic::String
	type::String
end

struct IPAvowel
	phoneme::String
	height::String
	backness::String
	roundness::Bool
	diacritics::Array{IPAvowelmodifier} # prev. called modifiers
end

struct IPAphoneticInventory
	consonants::Array{IPAconsonant} # IPApulmonic?
	vowels::Array{IPAvowel}
end

function getCharAndDiacritics(p)
	returnstring = p.phoneme
	if length(p.diacritics) > 0
		for d in p.diacritics
			returnstring *= d.diacritic # Check if the diacritic type has "pre", if so it should go in front.
		end
	end
	return returnstring
	#if type # Consonant vs Vowel
		
	#else

	#end

end
#=
pVoicing: false
pAspiration: true
prenasalize: false
fVoicing: false
=#

# DIACRITICS
ⁿ = IPAdiacritic('ⁿ', "Nasalized") # Prenasalize for consonants, nasal for vowels
ʰ = IPAdiacritic('ʰ', "Aspirated")
ʲ = IPAdiacritic('ʲ', "Palatized")
ʷ = IPAdiacritic('ʷ', "Labialized")
ˤ = IPAdiacritic('ˤ', "Pharyngealized")
ˀ = IPAdiacritic('ˀ', "Glottalized")
ᵝ = IPAdiacritic('ᵝ', "???")
ᵊ = IPAdiacritic('ᵊ', "???")
ʱ = IPAdiacritic('ʱ', "???")
ˡ = IPAdiacritic('ˡ', "???")
ʳ = IPAdiacritic('ʳ', "???")
ᵗ = IPAdiacritic('ᵗ', "???")
ˠ = IPAdiacritic('ˠ', "Velarized")

# TODO:
# Convert CSV to julia datastructure and save it

