#!/usr/bin/env bats

#WARNING!
#Dont use ((, cause (( $status == pp )) && echo Really WRONG!
#the issue is (( 0 == letters )) is always true ... :(


load test_helper

###########
#  BASIC  #
###########

b="./generate-autocompletion.sh"
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
[[ ${lines[1]} = "[STANDALONE]='-a --all -A --almost-all --author -b --escape -B --ignore-backups -d --directory -D --dired --file-type -G --no-group -h --human-readable --si -H --dereference-command-line -i --inode -L --dereference -n --numeric-uid-gid -N --literal -q --hide-control-chars --show-control-chars -Q --quote-name -r --reverse -R --recursive -s --size -Z --context --help --version'" ]]
[[ ${lines[2]} = "[ARG]='--block-size=SIZE --color[=WHEN] --format=WORD --full-time --hide=PATTERN --indicator-style=WORD -I --ignore=PATTERN -p --indicator-style=slash --quoting-style=WORD --sort=WORD --time=WORD --time-style=STYLE -T --tabsize=COLS -w --width=COLS'" ]]
[[ ${lines[3]} = "[VSTANDALONE]=''" ]]
[[ ${lines[4]} = "[VFLAG]=''" ]]
}

@test "command with both options 2" {
run $g tee
(( $status == 0 ))
[[ ${lines[0]} = " " ]] 
[[ ${lines[1]} = "[STANDALONE]='-a --append -i --ignore-interrupts --help --version'" ]]
[[ ${lines[2]} = "[ARG]=''" ]]
[[ ${lines[3]} = "[VSTANDALONE]=''" ]]
[[ ${lines[4]} = "[VFLAG]=''" ]]
}

###########
#  VERBS  #
###########

@test "command with verbs 1" {
run $g dd
(( $status == 0 ))
[[ ${lines[0]} = " " ]] 
[[ ${lines[1]} = "[STANDALONE]='--help --version'" ]]
[[ ${lines[2]} = "[ARG]=''" ]]
[[ ${lines[3]} = "[VSTANDALONE]='ascii ebcdic ibm block unblock lcase ucase swab sync excl nocreat notrunc noerror fdatasync fsync append direct directory dsync sync fullblock nonblock noatime nocache noctty nofollow'" ]]
[[ ${lines[4]} = "[VFLAG]='bs cbs conv count ibs if iflag obs of oflag seek skip status 9387674624'" ]]

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


