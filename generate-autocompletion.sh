#!/bin/bash 
#
# Generate automagically bash autocompletion for a command

#Version 0.1 Initial

__version=0.1
software=${0##*/}


function generate_case_arg(){
local com=$1

for arg in $(get_options_type $com "arg")
do
    echo -n "
    $arg)
    comps=''
    ;;"
done
}

function get_options_type(){
local args com=$1 regex line cleaned out
local regex
local -a arr
local type=$2
local stand='(-){1,2}([-[:alnum:]]+)([,[:space:]]+)([-[:alnum:]]+)'; 

mapfile -t args <<< "$(get_options $com)"
[[ -z $args ]] && return


if [[ $type == arg ]];
then
    regex='(-){1,2}([-[:alnum:]]+)(\[|=)'
else #standalone options can't include '[' or '='
    regex='*=*'
fi

# [[ $type != arg ]] && set -x

local total=$((${#args[@]}-1))
for num in $(eval echo {0..$total}); 
do 
    line=${args[num]}
    #option with args
    if [[ $type == arg  &&  $line =~ $regex ]] ; then
        #ugly but any other way???
        for w in $line; do [[ $w == -* ]] &&  arr=("${arr[@]}" "${w//,/}") || break; done
    fi
    # option without args (standalone)
    if [[ $type != arg  &&  $line != $regex ]] ; then
        if [[ $line =~ $stand ]]; then
            out="${BASH_REMATCH[0]}"
            #ugly but any other way???
            for w in $out; do [[ $w == -* ]] &&  arr=("${arr[@]}" "${w//,/}") || break; done
        fi
    fi
done
# [[ $type != arg ]] && set +x

echo "${arr[@]}"
}


function get_verbs_type(){
local args com=$1 regex value
local regex
local -a arr
local type=$2

if [[ $type == flag ]];
then
    regex='^([-_[:alnum:]]+)(=)([[:alnum:]]+)'
else
    regex='^([-_[:alnum:]]+)$'
fi

mapfile -t args <<< "$(get_verbs $com)"
[[ -z $args ]] && return

# [[ $type = flag ]] && set -x

local total=$((${#args[@]}-1))
for num in $(eval echo {0..$total}); 
do 
    value=${args[num]}
    [[ $value =~ $regex ]] && arr=("${arr[@]}" "${BASH_REMATCH[1]}") 

done
# [[ $type = flag ]] && set +x
echo "${arr[@]}"
}

function generate_template(){
local com=$1  output

[[ ! $com ]] && { echo "$com not found"; return; }

echo "
# $com(1) completion                                  -*- shell-script -*-
#
# This file is part of auto-autocompletion
#
# Copyright $(date +%Y) liloman <cual809@gmail.com>
#
# systemd is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 2.1 of the License, or
# (at your option) any later version.
#
# systemd is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with systemd; If not, see <http://www.gnu.org/licenses/>.


_$com () {
local cur=\${COMP_WORDS[COMP_CWORD]} prev=\${COMP_WORDS[COMP_CWORD-1]}
local i verb comps

local -A OPTS=(
[STANDALONE]='$(get_options_type $com "standalone")'
[ARG]='$(get_options_type $com "arg")'
)

if __contains_word "\$prev" \${OPTS[ARG]}; then
    case \$prev in
        $(generate_case_arg $com)
esac
COMPREPLY=( \$(compgen -W '\$comps' -- "\$cur") )
return 0
fi

if [[ "$cur" = -* ]]; then
    COMPREPLY=( $(compgen -W '${OPTS[*]}' -- "$cur") )
    return 0
fi

local -A VERBS=(
[STANDALONE]='$(get_verbs_type $com "standalone")'
[FLAG]='$(get_verbs_type $com "flag")'
)

for ((i=0; i < COMP_CWORD; i++)); do
    if __contains_word "\${COMP_WORDS[i]}" \${VERBS[*]} &&
        ! __contains_word "\${COMP_WORDS[i-1]}" \${OPTS[ARG]}; then
    verb=\${COMP_WORDS[i]}
    break
fi
        done

        if   [[ -z \$verb ]]; then
            comps="\${VERBS[*]}"
        elif __contains_word "\$verb" \${VERBS[STANDALONE]}; then
            comps=''
        fi

        COMPREPLY=( \$(compgen -W '\$comps' -- "\$cur") )
        return 0
    }

    complete -F _$com $com
    "
}


function get_options(){
local com line 
local regex='^([[:space:]]+)(-){1,2}([[:alnum:]]+)([,[:space:]]){,3}([-[:alnum:]]+)'
com=($1 --help)

while IFS= read -r line
do
    [[ $line =~ $regex ]] && echo "$line"
done < <("${com[@]}" 2>&1)
}

function get_verbs(){
local com line arr found 
local regex_verbs='^([[:space:]]){2,3}([[:alnum:]])(.*)'; 
com=($1 --help)

while IFS= read -r line
do
    if [[ $line =~ $regex_verbs ]]; then
        arr=(${line//[[:space:]]/ })
        echo ${arr[0]}
    fi
done < <("${com[@]}" 2>&1)
}

function filter(){
local value ret
value=$1
ret="true"

#Shall it leave out -M and -H or not?
[[ $value = -h || $value = --help 
|| $value = -M || $value = -H 
|| $value = --version ]] &&
    ret="false"
echo "$ret"
}


################################################################################
#                                     MAIN                                     #
################################################################################
function usage (){
echo "
$software [ PROGRAM ]

Generate automagically bash autocompletions

-h|help       Show this help
-t|test       Generate output for tests
-v|version    Show version
"
} 

while getopts ":hvt:" opt
do
    case $opt in
        h) 
            usage; exit 0 ;;
        v) 
            echo version: $__version; exit 0 ;;
        t)
echo " 
[STANDALONE]='$(get_options_type $OPTARG "standalone")'
[ARG]='$(get_options_type $OPTARG "arg")'
[VSTANDALONE]='$(get_verbs_type $OPTARG "standalone")'
[VFLAG]='$(get_verbs_type $OPTARG "flag")'"; 
exit ;;
        \?)
            echo -e "\n Incorrect option $OPTARG\n"; usage; exit 1 ;;
        :)  
            echo "Option -$OPTARG needs an argument"; exit 1 ;;
    esac   
done
shift $(($OPTIND-1))

[[ $# -eq 0 ]] && { echo Needs arguments. Try $software -h; exit 1;  }
generate_template $1

