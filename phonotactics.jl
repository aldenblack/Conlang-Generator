function buildPhonotactics(seed) 
	#(C)V(C), Word-initial, word-middle, word-final
	rng = MersenneTwister(seed)
	onset = 1
	coda = 0
	randval = rand(rng)
	onset += Int(floor(5*randval^2))
	randval = rand(rng)
	coda += Int(floor(5*randval^2))
	syllableStructure = (onset, coda)
	return syllableStructure
	#TODO: Turn probabilities into if-statement check to find exactly the distributions I want
	# Use curve-fitting algorithm (talk to kaleb later)


	# Onsets and codas tend to be similar in max length
	# Greater than 5 is very rare
	# CCCVCCCC strengths
	# CVC is most common, CV is required

	# longer mid-words are much less likely; CCVCC usually has CC midword, or C
	# This does create a lack of sound bias and a very uniform layout (no likely e or m or something). Allow this at first but not later — Probably in the Lexeme function and not here.
	# USE SET FOR WORD-INITIAL ETC -- no need, it constructs itself organizedly

	#Stress system
	# Initial, Second, Penultimate, Ultimate
end