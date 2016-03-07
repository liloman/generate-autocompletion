#!/usr/bin/env bats

#WARNING!
#Dont use ((, cause (( $status == pp )) && echo Really WRONG!
#the issue is (( 0 == letters )) is always true ... :(


load test_helper

###########
#  BASIC  #
###########

b=./generate-autocompletion.sh
g="$b -t"

@test "command without arguments" {
run $b 
(( $status == 1 ))
[[ ${lines[0]} = "Needs arguments. Try generate-autocompletion.sh -h" ]] 
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

@test "command without software" {
run $g 
(( $status == 1 ))
[[ ${lines[0]} = "Option -t needs an argument" ]] 
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

@test "command with verbs 1" {
run $g networkctl
(( $status == 0 ))
[[ ${lines[0]} = " " ]] 
[[ ${lines[1]} = "[STANDALONE]='-h --help --version --no-pager --no-legend -a --all'" ]]
[[ ${lines[2]} = "[ARG]=''" ]]
[[ ${lines[3]} = "[VSTANDALONE]='list lldp'" ]]
[[ ${lines[4]} = "[VFLAG]='status'" ]]
}

@test "command with verbs 2" {
run $g systemd-analyze
(( $status == 0 ))
[[ ${lines[0]} = " " ]] 
[[ ${lines[1]} = "[STANDALONE]='-h --help --version --no-pager --system --user --order --require'" ]]
[[ ${lines[2]} = "[ARG]='-H --host=[USER@]HOST -M --machine=CONTAINER --from-pattern=GLOB --to-pattern=GLOB --fuzz=SECONDS --man[=BOOL]'" ]]
[[ ${lines[3]} = "[VSTANDALONE]='time blame critical-chain plot dot dump'" ]]
[[ ${lines[4]} = "[VFLAG]='set-log-level verify'" ]]
}

@test "command with verbs 3" {
run $g loginctl
(( $status == 0 ))
[[ ${lines[0]} = " " ]] 
[[ ${lines[1]} = "[STANDALONE]='-h --help --version --no-pager --no-legend --no-ask-password -a --all -l --full'" ]]
[[ ${lines[2]} = "[ARG]='-H --host=[USER@]HOST -M --machine=CONTAINER -p --property=NAME --kill-who=WHO -s --signal=SIGNAL -n --lines=INTEGER -o --output=STRING'" ]]
[[ ${lines[3]} = "[VSTANDALONE]='list-sessions lock-sessions unlock-sessions list-users list-seats flush-devices'" ]]
[[ ${lines[4]} = "[VFLAG]='session-status show-session activate lock-session unlock-session terminate-session kill-session user-status show-user enable-linger disable-linger terminate-user kill-user seat-status show-seat attach terminate-seat'" ]]
}

############
#  EXTRAS  #
############


@test "command without autocompletion already" {
run $g stat
(( $status == 0 ))
[[ ${lines[0]} = " " ]] 
[[ ${lines[1]} = "[STANDALONE]='-L --dereference -f --file-system -t --terse --help --version'" ]]
[[ ${lines[2]} = "[ARG]='-c --format=FORMAT --printf=FORMAT'" ]]
[[ ${lines[3]} = "[VSTANDALONE]=''" ]]
[[ ${lines[4]} = "[VFLAG]=''" ]]
}


