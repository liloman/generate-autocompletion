#!/usr/bin/env bats

#WARNING!
#Dont use ((, cause (( $status == pp )) && echo Really WRONG!
#the issue is (( 0 == letters )) is always true ... :(


load test_helper

###########
#  BASIC  #
###########

b=generate-autocompletion.sh
g="$b -t"

@test "command without arguments" {
run $b 
(( $status == 1 ))
[[ ${lines[0]} = "Needs arguments. Try generate-autocompletion.sh -h" ]] 
}

@test "command without --help" {
run $g 
(( $status == 1 ))
[[ ${lines[0]} = "Option -t needs an argument" ]] 
}

@test "command without --help" {
run $g 
(( $status == 1 ))
[[ ${lines[0]} = "Option -t needs an argument" ]] 
}


@test "command without options/verbs" {
run $g type
(( $status == 0 ))
[[ ${lines[0]} = " " ]] 
[[ ${lines[1]} = "[STANDALONE]=''" ]]
[[ ${lines[2]} = "[ARG]=''" ]]
[[ ${lines[3]} = "[VSTANDALONE]=''" ]]
[[ ${lines[4]} = "[VFLAG]=''" ]]
}


#############
#  OPTIONS  #
#############

@test "command with standalone options only" {
run $g locale
(( $status == 0 ))
[[ ${lines[0]} = " " ]] 
[[ ${lines[1]} = "[STANDALONE]='-a --all-locales -m --charmaps -c --category-name -k --keyword-name -v --verbose --usage -V --version'" ]]
[[ ${lines[2]} = "[ARG]=''" ]]
[[ ${lines[3]} = "[VSTANDALONE]=''" ]]
[[ ${lines[4]} = "[VFLAG]=''" ]]
}

@test "command with both options " {
run $g ls
(( $status == 0 ))
[[ ${lines[0]} = " " ]] 
[[ ${lines[1]} = "[STANDALONE]='-a --all -A --almost-all --author -b --escape -B --ignore-backups -d --directory -D --dired --file-type -G --no-group -h --human-readable --si -H --dereference-command-line -i --inode -k --kibibytes -L --dereference -n --numeric-uid-gid -N --literal -q --hide-control-chars --show-control-chars -Q --quote-name -r --reverse -R --recursive -s --size -Z --context --help --version'" ]]
[[ ${lines[2]} = "[ARG]='--block-size=SIZE --color[=WHEN] --format=WORD --full-time --hide=PATTERN --indicator-style=WORD -I --ignore=PATTERN -p --indicator-style=slash --quoting-style=WORD --sort=WORD --time=WORD --time-style=STYLE -T --tabsize=COLS -w --width=COLS'" ]]
[[ ${lines[3]} = "[VSTANDALONE]=''" ]]
[[ ${lines[4]} = "[VFLAG]=''" ]]
}

@test "command with both options 2" {
run $g tee
(( $status == 0 ))
[[ ${lines[0]} = " " ]] 
[[ ${lines[1]} = "[STANDALONE]='-a --append -i --ignore-interrupts --help --version'" ]]
[[ ${lines[2]} = "[ARG]='-p --output-error[=MODE]'" ]]
[[ ${lines[3]} = "[VSTANDALONE]=''" ]]
[[ ${lines[4]} = "[VFLAG]=''" ]]
}

###########
#  VERBS  #
###########

@test "command with standalone verbs " {
run $g systemd-analyze
(( $status == 0 ))
[[ ${lines[0]} = " " ]] 
[[ ${lines[1]} = "[STANDALONE]='-h --help --version --no-pager --system --user --order --require'" ]]
[[ ${lines[2]} = "[ARG]='-H --host=[USER@]HOST -M --machine=CONTAINER --from-pattern=GLOB --to-pattern=GLOB --fuzz=SECONDS --man[=BOOL]'" ]]
[[ ${lines[3]} = "[VSTANDALONE]='time blame critical-chain plot dot set-log-level dump verify'" ]]
[[ ${lines[4]} = "[VFLAG]=''" ]]
}
