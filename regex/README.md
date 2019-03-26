
# Regex Intro

Def: generalize a pattern, search and match that pattern

## Where to use Regex:

* Programming: 
    - Python
    - perl
    - ...
* Text processing:
    - awk
    - sed
* other applications

## Where to test them:

* (regexr)[https://regexr.com/]
* (regex101)[https://regex101.com/]
* (regexpal)[https://www.regexpal.com/]
* ...


## Regex engines

Regex are based on 2 algorithmes:
    - NFA: Non deterministic Finite automaton
    - DFA: deterministic Finite automaton

* NFA based engines( can go back in the regex):
    - Python
    - Vim
    - sed
    - ...

* DFA based engine (cannot go back):
    - grep
    - awk

-> Newer versions of `grep` and `awk` use both.

## Regex standards

IEEE POSIX standards: DFA friendly, implements three standards:
    - BRE
    - ERE
    - SRE
  * ERE builds off BRE

PCRE Standards: Perl Compatible Regex Expressions:
  * used by other standards such as Java, python, .net .
  * There is some differences between Perl active implementation and PCRE
  * NFA minded


# Regex

## Matching word and caracters

[ABD]: match these three capital caracters.
[A-D]: match the range of caracters from A to D
\W   : Match a non word caracter ( not A-Z, a-z, 0-9).
\w   : Match a word Caracter (A-Z, a-z, 0-9), each instance of \w is a single caracter.
\D   : Match a non digit caracter
\d   : Match a single digit caracter.
[5-9]: Match a range of numbers( from 5 to 9 )