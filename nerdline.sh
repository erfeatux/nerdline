#!/bin/env bash

# Nerdline
# Copyright (C) 2024 Eduard Litovskikh (nicknames: Erfea, Yumi Cyannis; mail: erfea.tux at gmail)
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# shellcheck disable=SC1090,SC1091,SC2001,SC2025,SC2154

function __nerdline_tmp_load_configs()
{
	#Clear (delete all variables used in the previous runtime)
	unset "${!__nerdline_separato@}"
	unset __nerdline_segments __nerdline_modules
	unset PROMPT_COMMAND


	#Searching actual configs
	if [[ -r /etc/nerdline.cfg ]]
	then
		__nerdline_tmp_load_config /etc/nerdline.cfg
	fi
	
	if [[ -n $XDG_CONFIG_HOME ]]
	then
		__nerdline_tmp_cfg="$XDG_CONFIG_HOME/nerdline.cfg"
	else
		__nerdline_tmp_cfg="$HOME/.config/nerdline.cfg"
	fi
	if [[ -r $__nerdline_tmp_cfg ]]
	then
		__nerdline_tmp_load_config "$__nerdline_tmp_cfg"
	fi

	if [[ -z $__nerdline_separator ]]
	then #Separator between sections with different background colors
		__nerdline_separator=' '
	fi
	if [[ -z $__nerdline_separator_same_bg ]]
	then #Separator between sections with the same background colors
		__nerdline_separator_same_bg='░ '
	fi

	if [[ -z ${__nerdline_segments} ]]
	then
		if [[ -z ${__nerdline_segments_ssh} ]]
		then
			__nerdline_segments='user hostname python hist git pwd jobs retcode'
		else
			__nerdline_segments="${__nerdline_segments_ssh}"
		fi
	fi

	if ! cd "$__nerdline_pfx"
	then
		error 30 "Can't cd to nerdline prefix '${__nerdline_pfx}'";return $?
	fi
	__nerdline_tarball="$(XZ_OPT=-e tar -cJf - ./nerdline.sh ./modules/ ./segments/ ./lib/ | base64 -w 0)"
	if [[ ${#__nerdline_tarball} -lt 4096 ]]
	then
		error 31 "Can't make tarball";return $?
	fi
	__nerdline_tarball_sum="$(echo -n "$__nerdline_tarball" | sha1sum)"
	__nerdline_tarball_sum="${__nerdline_tarball_sum%%\ *}"
	if [[ ! $__nerdline_tarball_sum =~ ^[A-Za-z0-9]{40}$ ]]
	then
		error 32 "Invalid tarball checksum '$__nerdline_tarball_sum'";return $?
	fi
	cd "$OLDPWD" || error 33 "Can't cd back to old pwd"
}


_nl_bg='\[\e[48:2::'
_nl_fg='\[\e[38:2::'
_nl_end='m\]'
_nl_clr='\[\e[m\]'


##################################################################
if [[ $1 == test ]] ##############################################
then #Test (use it before sourcing file) #########################
	__nerdline_pfx=$(dirname "$(readlink -f "$0")")
	source "$__nerdline_pfx/lib/functions.sh" error
	source "$__nerdline_pfx/lib/functions.sh" config
	__nerdline_tmp_load_configs

	if [[ ${COLORTERM} != truecolor ]]
	then
		error 2 'Not truecolor terminal'
	fi
	if [[ ${TERM} =~ screen.* ]] || [[ -n ${STY} ]] || [[ -n ${TMUX} ]]
	then
		error 3 'Not for screen and tmux'
	fi

	#set modules received over ssh
	if [[ -z ${__nerdline_modules} ]] && [[ -n ${__nerdline_modules_ssh} ]]
	then
		export __nerdline_modules="${__nerdline_modules_ssh}"
	fi

	export "${!__nerdline_@}"
	for __nerdline_tmp_modname in ${__nerdline_modules}
	do
		"${__nerdline_pfx}/modules/${__nerdline_tmp_modname}.sh" test || error 3 "Module '${__nerdline_tmp_modname}' testing failed"
	done
	__nerdline_tmp_cnt=0
	for segment in ${__nerdline_segments}
	do
		if ! "${__nerdline_pfx}/segments/${segment}.sh" test
		then
			error 4 "Segment '$segment' testing failed"
		fi
		(( __nerdline_tmp_cnt+=1 ))
	done
	if [[ $__nerdline_tmp_cnt -lt 1 ]]
	then
		error 5 'No segments'
	fi

	exit 0


##################################################################
elif [[ ${BASH_SOURCE[0]} != "$0" ]] #############################
then #Sourcing this file #########################################
	__nerdline_pfx="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
	export __nerdline_pfx
	source "$__nerdline_pfx/lib/functions.sh" error-sourcing
	source "$__nerdline_pfx/lib/functions.sh" config
	__nerdline_tmp_load_configs
	export __nerdline_segments __nerdline_modules
	export "${!__nerdline_tarball@}"

	#set modules received over ssh
	if [[ -z ${__nerdline_modules} ]] && [[ -n ${__nerdline_modules_ssh} ]]
	then
		export __nerdline_modules="${__nerdline_modules_ssh}"
	fi

	source "$__nerdline_pfx/lib/functions.sh" nerdline

	if [[ -r /etc/bash.bashrc ]]
	then
		source /etc/bash.bashrc
	fi
	if [[ -r ~/.bashrc ]]
	then
		source ~/.bashrc
	fi

	#Getting the current background color of the terminal
	stty -echo >/dev/null 2>&1
	echo -ne '\e]11;?\a'
	while [[ -z $__nerdline_tmp_bg ]]
	do
		IFS=':' read -r -t 0.05 -d $'\a' x __nerdline_tmp_bg
	done
	echo "$x" >/dev/null 2>&1; unset x
	stty echo >/dev/null 2>&1
	IFS='/' read -ra __nerdline_tmp_c <<< "$__nerdline_tmp_bg"
	export __nerdline_term_bg="$(($((16#"${__nerdline_tmp_c[0]}"))/256)):$(($((16#"${__nerdline_tmp_c[1]}"))/256)):$(($((16#"${__nerdline_tmp_c[2]}"))/256))"


	for __nerdline_tmp_modname in ${__nerdline_modules}
	do #Sourcing modules
		source "${__nerdline_pfx}/modules/${__nerdline_tmp_modname}.sh"
	done
	for __nerdline_tmp_segment in ${__nerdline_segments}
	do #Sourcing segments
		source "${__nerdline_pfx}/segments/${__nerdline_tmp_segment}.sh"
	done

	if [[ -n $__nerdline_separator_color ]]
	then
		__nerdline_tmp_parseColors '__nerdline_separator_color'
	fi

	#clean
	for __nerdline_tmp_fnc in $(compgen -A function __nerdline_tmp_)
	do
		unset "$__nerdline_tmp_fnc"
	done
	unset error
	unset "${!_nl_@}"
	unset "${!__nerdline_tmp_@}"

	PROMPT_COMMAND='export __nerdline_tmp_retcode=$?;'
	PROMPT_COMMAND+='if [[ $(type -t __nerdline_update) == function ]];'
	PROMPT_COMMAND+='then __nerdline_update > /dev/null 2>&1 || '
	PROMPT_COMMAND+='if [[ -r "${__nerdline_pfx}/nerdline.sh" ]];'
	PROMPT_COMMAND+='then source "${__nerdline_pfx}/nerdline.sh";'
	PROMPT_COMMAND+='__nerdline_update > /dev/null 2>&1;fi;fi'
	export PROMPT_COMMAND


##################################################################
else #############################################################
	__nerdline_pfx=$(dirname "$(readlink -f "$0")")

	if [[ $1 == tests ]]
	then #Run all tests ###############################################
		# shellcheck disable=SC1091
		source "$__nerdline_pfx/lib/functions.sh" error

		__nerdline_tests_clr_pass='\033[0;32m'
		__nerdline_tests_clr_fail='\033[0;31m'
		__nerdline_tests_clr_reset='\033[0m'

		__nerdline_tests_total=0
		__nerdline_tests_passed=0
		__nerdline_tests_failed=0

		echo "Running all tests..."
		echo ""

		__nerdline_tests_dirs=("$__nerdline_pfx/tests/unit" "$__nerdline_pfx/tests/segments" "$__nerdline_pfx/tests/modules" "$__nerdline_pfx/tests/integration")

		for __nerdline_tests_dir in "${__nerdline_tests_dirs[@]}"
		do
			if [[ -d "$__nerdline_tests_dir" ]]
			then
				while IFS= read -r -d '' __nerdline_tests_file
				do
					[[ -x "$__nerdline_tests_file" ]] && continue
					__nerdline_tests_name="$(basename "$__nerdline_tests_file" .sh)"
					echo "=== $__nerdline_tests_name ==="

					__nerdline_tests_output="$(TERMSHELL=bash __nerdline_pfx="$__nerdline_pfx" bash "$__nerdline_tests_file" 2>&1)"
					echo "$__nerdline_tests_output"

					if [[ "$__nerdline_tests_output" =~ Tests:\ ([0-9]+),\ Passed:\ ([0-9]+),\ Failed:\ ([0-9]+) ]]
					then
						__nerdline_tests_total=$((__nerdline_tests_total + BASH_REMATCH[1]))
						__nerdline_tests_passed=$((__nerdline_tests_passed + BASH_REMATCH[2]))
						__nerdline_tests_failed=$((__nerdline_tests_failed + BASH_REMATCH[3]))
					fi
				done < <(find "$__nerdline_tests_dir" -maxdepth 1 -name '*.sh' -print0)
			fi
		done

		echo ""
		echo "================================"
		echo "Total: $__nerdline_tests_total, Passed: $__nerdline_tests_passed, Failed: $__nerdline_tests_failed"
		echo "================================"

		if [[ $__nerdline_tests_failed -gt 0 ]]
		then
			echo -e "${__nerdline_tests_clr_fail}FAILED${__nerdline_tests_clr_reset}"
			exit 1
		else
			echo -e "${__nerdline_tests_clr_pass}PASSED${__nerdline_tests_clr_reset}"
			exit 0
		fi

	elif [[ -n $1 ]] && [[ $__nerdline_modules =~ (^|\ )$1($|\ ) ]]
	then
		__nerdline_tmp_args=( "${@}" )
		__nerdline_tmp_args=( "${__nerdline_tmp_args[@]:1}" )
		"${__nerdline_pfx}/modules/${1}.sh" "${__nerdline_tmp_args[@]}"
		exit $?
	fi

	echo -e '\e[33;40musage: nerdline <action> [options]\n\e[0m'
	echo -e '\e[37;40mactions:\e[0m'
	echo -e '\e[36;40m\tupdate\t\tRestart nerdline, -f/--force option reloads its config\e[0m'
	echo -e '\e[36;40m\ttest\t\tConfiguration and integrity check\e[0m'
	echo -e '\e[36;40m\ttests\t\tRun all unit, segment, module and integration tests\e[0m'
	for __nerdline_tmp_modname in ${__nerdline_modules}
	do
		__nerdline_tmp_modname_help="__nerdline_mds_${__nerdline_tmp_modname}_help"
		echo -e "\e[36;40m\t${__nerdline_tmp_modname}\t\t${!__nerdline_tmp_modname_help}\e[0m"
	done
fi

