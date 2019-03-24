
# Regex

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
