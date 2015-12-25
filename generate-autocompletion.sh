#!/usr/bin/env bash
#
# Generate automagically bash autocompletion for a command

#Version 0.1 Initial with options and verbs working

__version=0.1
software=${0##*/}


function generate_case_arg(){
local com=$1

for arg in $(get_options_type $com "arg" "join")
do
    echo -n "
    $arg)
    comps=''
    ;;"
done
}

#Detect option type, standalone (without arg) o arg
function get_options_type(){
local args com=$1 regex line cleaned out
local regex
local -a arr
local type=$2
local join=$3
local joins=
local stand='(-){1,2}([-[:alnum:]]+)([,[:space:]]+)([-[:alnum:]]+)'; 

mapfile -t args <<< "$(get_options $com)"
[[ -z $args ]] && return


if [[ $type == arg ]];
then
    regex='(-){1,2}([-[:alnum:]]+)(\[|=)'
else #standalone options can't include '[' or '='
    regex='*=*'
fi

# [[ $type = arg ]] && set -x

local total=$((${#args[@]}-1))
for num in $(eval echo {0..$total}); 
do 
    line=${args[num]}
    #option with args
    if [[ $type == arg  &&  $line =~ $regex ]] ; then
        if [[ -z $join ]]; then # It is generating normal autocompletion
            for w in $line; do [[ $w == -* ]] &&  arr=("${arr[@]}" "${w//,/}") || break; done
        else #It is generating cases for flags (verbs with args)
            for w in $line; do 
                if [[ $w == -* ]]; then 
                    [[ -n $joins ]] && joins+="|${w//,/}" 
                    [[ -z $joins ]] && joins="${w//,/}" 
                else
                    arr=("${arr[@]}" "$joins") 
                    joins=
                    break; 
                fi
            done
        fi
    fi
    # option without args (standalone)
    if [[ $type != arg  &&  $line != $regex ]] ; then
        if [[ $line =~ $stand ]]; then
            out="${BASH_REMATCH[0]}"
            for w in $out; do [[ $w == -* ]] &&  arr=("${arr[@]}" "${w//,/}") || break; done
        fi
    fi
done
# [[ $type = arg ]] && set +x

echo "${arr[@]}"
}


#Detect verb type, standalone (without flag) o flag
function get_verbs_type(){
local args com=$1 regex value
local regex
local -a arr
local type=$2

if [[ $type == flag ]];
then
    regex='^([[:space:]]){2,3}([-_[:alnum:]]+)(=|[[:space:]])(\[?)([[:alnum:]]+)(]?)'
else
    regex='^([[:space:]]){2,3}([-_[:alnum:]]+)([[:space:]]){2,}'
fi

mapfile -t args <<< "$(get_verbs $com)"
[[ -z $args ]] && return

# [[ $type = flag ]] && set -x

local total=$((${#args[@]}-1))
for num in $(eval echo {0..$total}); 
do 
    value="${args[num]}"
    [[ $value =~ $regex ]] && arr=("${arr[@]}" "${BASH_REMATCH[2]}") 

done
# [[ $type = flag ]] && set +x

echo "${arr[@]}"
}

function generate_template(){
local com=$1 dir file 
hash $com &>/dev/null || { echo "$com not found"; return; }

dir=${BASH_COMPLETION_USER_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/bash-completion}/completions
[[ -d $dir ]] || mkdir -p $dir
file=$dir/$com

#No easy way to detect bash autocompletion function from here...
# if declare -F _$com; then
#     echo "_$com already exists"
#     read -n 1 -p "Do you want to overwrite it (y/n)? " answer
#     case ${answer} in
#         y|Y )
#             echo Overwriting so...
#             ;;
#         * )
#             echo Exit.
#             return
#             ;;
#     esac
# fi

echo "
# $com(1) completion                                  -*- shell-script -*-
#
# This file is part of $software
#
# Copyright $(date +%Y) liloman <cual809@gmail.com>
#
# $software is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 2.1 of the License, or
# (at your option) any later version.
#
# $software is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with $software; If not, see <http://www.gnu.org/licenses/>.

__contains_word () {
        local w word=\$1; shift
        for w in \"\$@\"; do
                [[ \$w = \"\$word\" ]] && return
        done
}


_$com () {
local cur=\${COMP_WORDS[COMP_CWORD]} prev=\${COMP_WORDS[COMP_CWORD-1]}
local i verb comps

local -A OPTS=(
[STANDALONE]='$(get_options_type $com "standalone")'
[ARG]='$(get_options_type $com "arg")'
)

if __contains_word \"\$prev\" \${OPTS[ARG]}; then
    case \$prev in
        $(generate_case_arg $com)
esac
COMPREPLY=( \$(compgen -W '\$comps' -- "\$cur") )
return 0
fi

if [[ \"\$cur\" = -* ]]; then
    COMPREPLY=( \$(compgen -W '\${OPTS[*]}' -- \"\$cur\") )
    return 0
fi

local -A VERBS=(
[STANDALONE]='$(get_verbs_type $com "standalone")'
[FLAG]='$(get_verbs_type $com "flag")'
)

for ((i=0; i < COMP_CWORD; i++)); do
    if __contains_word \"\${COMP_WORDS[i]}\" \${VERBS[*]} &&
        ! __contains_word \"\${COMP_WORDS[i-1]}\" \${OPTS[ARG]}; then
    verb=\${COMP_WORDS[i]}
    break
    fi
done

if   [[ -z \$verb ]]; then
    comps=\"\${VERBS[*]}\"
elif __contains_word "\$verb" \${VERBS[STANDALONE]}; then
    comps=''
fi

COMPREPLY=( \$(compgen -W '\$comps' -- \"\$cur\") )
return 0
}

complete -F _$com $com
" > $file 

echo -e "To get the new autocompletion, open a new terminal or run:\nsource ${file/$HOME/\~}\n"
}


#Return the full lines with an option inside
function get_options(){
local com line 
local regex='^([[:space:]]+)(-){1,2}([[:alnum:]]+)([,[:space:]]){,3}([-[:alnum:]]+)'
com=($1 --help)

while IFS= read -r line
do
    [[ $line =~ $regex ]] && echo "$line"
done < <("${com[@]}" 2>&1)
}

#Return the full lines with an verb inside
function get_verbs(){
local com line arr found 
local regex_verbs='^([[:space:]]){2,3}([[:alnum:]])(.*)'; 
com=($1 --help)

while IFS= read -r line
do
    [[ $line =~ $regex_verbs ]] && echo "$line"
done < <("${com[@]}" 2>&1)
}


################################################################################
#                                     MAIN                                     #
################################################################################
function usage (){
echo "
$software [ PROGRAM ]

Generate automagically bash autocompletions

 -h, --help  Show this help
 -t  Generate output for tests
 -v  Show version
"
} 

# Use getopt to parse parameters
if ! OPTIONS=$(getopt -n "$software" -o htv -l "help" -- "$@"); then
    usage
    exit 0
fi

eval set -- "${OPTIONS}"

# And now parse options with while
while true; do
    case "$1" in
        "--help"|"-h")
            usage; exit 0 ;;

        "-t")
             [[ -z $3 ]] && { echo "Option -t needs an argument";exit 1; }
             hash $3 &>/dev/null || { echo "$3 not found"; exit 1; }
echo " 
[STANDALONE]='$(get_options_type $3 "standalone")'
[ARG]='$(get_options_type $3 "arg")'
[VSTANDALONE]='$(get_verbs_type $3 "standalone")'
[VFLAG]='$(get_verbs_type $3 "flag")'"; 
exit ;;
        "-v") 
            echo version: $__version; exit 0 ;;
        "--")
            shift; break ;;
    esac   
done

[[ $# -eq 0 ]] && { echo Needs arguments. Try $software -h; exit 1;  }
generate_template $1

