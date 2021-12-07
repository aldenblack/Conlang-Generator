using CSV
using DataFrames

# TODO:
# Convert CSV to julia datastructure and save it
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

# PHONEME DATA

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

const IPAvowels = [
	[('i', 'y'), ('ɨ', 'ʉ'), ('ɯ', 'u')],
	[('ɪ', 'ʏ'), ('*', '*'), ('*', 'ʊ')],
	[('e', 'ø'), ('ɘ', 'ɵ'), ('ɤ', 'o')],
	[('*', '*'), ('ə', '*'), ('*', '*')],
	[('ɛ', 'œ'), ('ɜ', 'ɞ'), ('ʌ', 'ɔ')],
	[('æ', '*'), ('ɐ', '*'), ('*', '*')], 
	[('a', 'ɶ'), ('*', '*'), ('ɑ', 'ɒ')] # ɚɝɛ̃ʋⱱ
]
CLOSE = 1
NEARCLOSE = 2
CLOSEMID = 3
MID = 4
OPENMID = 5
NEAROPEN = 6
OPEN = 7
FRONT = 1
CENTRAL = 2
BACK = 3
vowelHeight = Dict(
	1 => "Close",
	2 => "Nearclose",
	3 => "Closemid",
	4 => "Mid",
	5 => "Openmid",
	6 => "Nearopen",
	7 => "Open"
	)
vowelBackness = Dict(
	1 => "Front",
	2 => "Central",
	3 => "Back"
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
	height::String # Openness
	backness::String
	roundness::Bool # true is round
	diacritics::Array{IPAdiacritic} # prev. called modifiers
end

struct IPAphoneticInventory
	consonants::Array{IPAconsonant} # IPApulmonic?
	vowels::Array{IPAvowel}
end

function getCharAndDiacritics(p)
	returnstring = string(p.phoneme)
	if length(p.diacritics) > 0
		for d in p.diacritics 
			if d.type[1:3] == "Pre"
				returnstring = d.diacritic * returnstring
			elseif d.type == "Dentalized" # Fixes ts̪, reliant on dentalize coming before prenasalize
				returnstring = returnstring[1]*d.diacritic*returnstring[2:end] # 1156170593
			else
				returnstring *= d.diacritic # Check if the diacritic type has "pre", if so it should go in front.
			end
		end
	end
	return returnstring
	#if type # Consonant vs Vowel
		
	#else

	#end

end

""" Helper function used for consonant inventory construction choose whether two values should be identical."""
function sameWithMargin(randval, base, margin)
	return randval < margin ? !base : base
end

#=
pVoicing: false
pAspiration: true
prenasalize: false
fVoicing: false
=#

# DIACRITICS
#◌ = IPAdiacritic(nothing, "No Diacritic") 
ⁿ = IPAdiacritic('ⁿ', "Prenasalized") # Prenasalize for consonants, nasal for vowels
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
dental = IPAdiacritic('̪', "Dentalized")
# Vowel Diacritics 
ː = IPAdiacritic('ː', "Long")
ˑ = IPAdiacritic('ˑ', "Half-Long")
◌̃ = IPAdiacritic('˜', "Nasal") # ◌̃˜ 
◌˞ = IPAdiacritic('˞', "Rhotic") 

# GRAMMAR DATA

struct Grammar
	mainWordOrder::String
	fullWordOrder::Array{String}
	alignment::String

end
# Data taken from https://en.wikipedia.org/wiki/Word_order#Distribution_of_word_order_types Dryer 2005 Study
const SOV = 0.405
const SVO = 0.354
const VSO = 0.069
const VOS = 0.021
const OVS = 0.007
const OSV = 0.003
const UNFIXED = 0.141

const N = "Noun"
const DEM = "Demonstrative"
const NUM = "Number"
const POS = "Possessive"
const GEN = "Genitive"
const ADJ = "Adjective"
const REL = "Relative"

PP = "Prepositional Phrase"
NP = "Noun Phrase"
VP = "Verb Phrase"
DT = "Determiner Phrase"