# Overview

Protolang is a conlang (constructed language) generator made for writers and worldbuilders. With a few clicks, you can generate the sounds, grammar, and core vocabulary of a new language! 

## How To Use

Protolang is currently accessible as a terminal app. 

Run `julia main.jl` from within the file. You will be prompted with:
```
Commands:
r, run, reload - create and display language
l, load <seed> - load language with seed (ex. load 72548917)
q, quit, exit - exit
```

Current output consists of a phoneme inventory and grammar overview, as well as a small starter lexicon. 

Note: It is recommended that you save the whole language file for any languages you want to keep rather than just saving the seed, as this project is still under construction and the generation algorithm is liable to change over time.

### Features:

- Realistic consonant and vowel generation
- Starter dictionary for your conlang
- Rudimentary grammatical structure construction (phrase order structure)
- Grammar transliteration for annotated examples

### Under Construction:

- Exporting to files (save function)
- Declension and conjugation tables for nouns and verbs (with examples in English)
- Expanded Lexicon
- English to Conlang Translation using the conlang starter dictionary

### Dependencies

 The [Julia](https://julialang.org/) language is required to run Protolang.

# Resources
[International Phonetic Alphabet](https://www.internationalphoneticassociation.org/sites/default/files/IPA_Kiel_2015.pdf)

[IPA Wikiepdia Page](https://en.wikipedia.org/wiki/International_Phonetic_Alphabet)

[Cross-linguistic Phoneme Frequencies](https://phoible.org/parameters)

[World Atlas of Language Structures](https://wals.info) (Source of most frequencies for grammatical elements)

[Leipzig Glossing Rules](https://www.eva.mpg.de/lingua/resources/glossing-rules.php)

[Universal Language Dictionary](https://www.frathwiki.com/Universal_Language_Dictionary) (Lexicon generation based largely on this source)

