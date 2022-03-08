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
# Translate IPAconsonant place with eval(Meta.parse(uppercase(consonant.place)))
const BILABIAL = 1
LABIOVELAR = 1
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
CLICK = 2.4
AFFRICATE = 2.5
EJECTIVE = 2.6
IMPLOSIVE = 2.7
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
	[('a', 'ɶ'), ('*', '*'), ('ɑ', 'ɒ')] # ɚɝɛ̃ʋⱱ #FIXME: Should a be central to cut off supply to a, or stay to cut off æ 
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

abstract type IPA end

abstract type IPAchr <: IPA end

struct IPAdiacritic <: IPA
	diacritic::Char
	type::String
end

struct IPAconsonant <: IPAchr # Pulmonic and nonpulmonic; click and voiced implosive are manner, ejectives how? 
	phoneme::Union{String, Char}
	place::String
	manner::String
	voice::Bool 
	diacritics::Array{IPAdiacritic}
end

struct IPAvowelmodifier <: IPA # Include tone, nasal, and length
	diacritic::String
	type::String
end

struct IPAvowel <: IPAchr
	phoneme::Union{String, Char}
	height::String # Openness
	backness::String
	roundness::Bool # true is round
	diacritics::Array{IPAdiacritic} # prev. called modifiers
end

struct IPAphoneticInventory <: IPA
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

""" Returns a boolean describing whether a consonant is nonpulmonic"""
function nonpulmonic(consonant::IPAconsonant)
	return lowercase(consonant.manner) == "implosive" || 
			occursin("ejective", lowercase(consonant.manner)) || 
			lowercase(consonant.manner) == "click"
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
	NPStructure::Array{String}
	VPStructure::Array{String}
	prepositions::Bool
	alignment::String
	adjEncoding::Int
end
# Data taken from https://en.wikipedia.org/wiki/Word_order#Distribution_of_word_order_types Dryer 2005 Study
const SOV = "Subject Object Verb"
const SVO = "Subject Verb Object"
const VSO = "Verb Subject Object"
const VOS = "Verb Object Subject"
const OVS = "Object Verb Subject"
const OSV = "Object Subject Verb"
const UNFIXED = "Unfixed"
const UNF = "Unfixed"

const N = "Noun"
const DEM = "Demonstrative"
const NUM = "Number"
const POS = "Possessive"
const GEN = "Genitive"
const ADJ = "Adjective"
const REL = "Relative"
const ADP = "Adposition"

const V = "Verb"
const SUB = "Subject"
const OBJ = "Direct Object"
const INDOBJ = "Indirect Object"

 
PPhrase = "Prepositional Phrase"
NPhrase = "Noun Phrase"
VPhrase = "Verb Phrase"
DTPhrase = "Determiner Phrase"

const NOMACC = "Nominative/Accusative"
const NOMMAR = "Nominative/Accusative - Marked Nominative"
const ERGABS = "Ergative/Absolutive"
const TRIPAR = "Tripartite"
const ACTSTA = "Active/Stative"
const DIRECT = "Direct"
# Austronesian? - Agreement between verb marking and single marked argument
# Split (alignment change by tense, aspect, or animacy/gender) - TBA

# MORPHOLOGY DATA
struct NounClassSystem
	pronounOnly::Bool
	genderType::Union{String, Nothing}
end

const MASC = "Masculine"
const FEM = "Feminine"
const NEUT = "Neuter"

const genderClasses = [MASC, FEM, NEUT] #FIXME: Use sets; they have built in functions to pop a random element
const animacyClasses = []

struct GrammarTable
	cases::Array{Tuple{String, String}}
end

# LEXICON DATA
struct LexEntry
	word
	PoS 
	animacy # include hierarchy/range of animacy for animate-gendered language, i. e. 1:2 or classify by type (plant, divine, human)
end

abstract type PoS end
struct Noun <: PoS
	translation
	word
	gender
	animacy
end
struct Verb <: PoS
	translation
	word
	transitive
	dative
end
struct Adposition <: PoS
	translation
	word
end
abstract type Descriptor <: PoS end
struct Adjective <: Descriptor
	translation
	word
	agreement # Nominal or verbal treatment
	class
end
struct Adverb <: Descriptor
	translation
	word
end

println("Reading Dictionary...")
vocabList = CSV.read("vocablist.csv", DataFrame)


# OUTPUT 
function Base.zero(::Type{IPAconsonant})
	return IPAconsonant("", "", "", false, IPAdiacritic[])
end
function Base.zero(::Type{String})
	return ""
end


# TRANSLATION 
abstract type Phrase end
struct MP <: Phrase # Adverb-like modifiers
    head::String
    dependent::Union{MP, Nothing}
end
struct DP <: Phrase # Determiners and other nominal modifiers
    head::Union{DP, String}
    headPoS::String
    dependent::Union{DP, MP, Nothing}
end
struct NP{T} <: Phrase
    head::Union{NP, String}
    dependent::Union{Phrase, Nothing}
    NP(x, y) = typeof(y) <: Union{DP, PP, RP, Nothing} ? new{Phrase}(x, y) : error("improper phrase contents")
end
struct VP <: Phrase # Contains the verb and its object. Nesting a VP in a VP allows reference of the indirect object. (or insert an MP)
    head::Union{VP, String}
    dependent::Union{MP, NP, Nothing}
end
struct Root <: Phrase # Root of a clause, with a subject and verb.
    head::VP
    dependent::Union{NP, Nothing}
end
struct RP <: Phrase
    head::String
    dependent::Union{Root, VP}
end
struct PP <: Phrase
    head::String
    dependent::Union{NP, Nothing}
end
# TODO: Grammaticalized version of translation, in which nouns, verbs, and adjectives carry declension information (e.g. 1P.SG.PRS.PRF) to translate to the best equivalent


