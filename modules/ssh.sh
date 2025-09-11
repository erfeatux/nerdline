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

# shellcheck disable=SC1091,SC2154

##################################################################
if [[ $1 == test ]] ##############################################
then #Test (use it before sourcing file) #########################
	source "$__nerdline_pfx/lib/functions.sh" error
	if [[ -z $__nerdline_tarball ]] || [[ -z $__nerdline_tarball_sum ]]
	then
		error 11 'Tarball is not defined'
	fi


##################################################################
elif [[ $1 == connect ]] #########################################
then #Start ssh connection #######################################
	source "$__nerdline_pfx/lib/functions.sh" error
	__nerdline_tmp_ssh_bin="$(which ssh)"
	"${__nerdline_tmp_ssh_bin}" -V > /dev/null 2>&1 || error 13 "Can't find ssh binary"
	__nerdline_tmp_ssh_args=( "$@" )
	__nerdline_tmp_ssh_args=( "${__nerdline_tmp_ssh_args[@]:1:$((${#__nerdline_tmp_ssh_args}-1))}" )

	__nerdline_tmp_ssh_dest=
	__nerdline_tmp_ssh_dest_args=()
	__nerdline_tmp_ssh_parsed_args=()
	__nerdline_tmp_ssh_prev_arg=
	__nerdline_tmp_ssh_targ_exist=
	for __nerdline_tmp_ssh_arg in "${__nerdline_tmp_ssh_args[@]}"
	do
		if [[ $__nerdline_tmp_ssh_arg =~ ^-[bcDeEFiIJlLmoOpQRSwW]$ ]] && [[ -z $__nerdline_tmp_ssh_dest ]]
		then #need subarg
			if [[ -n $__nerdline_tmp_ssh_prev_arg ]]
			then
				error 14 "Invalid arg '$__nerdline_tmp_ssh_arg'"
			fi
			__nerdline_tmp_ssh_prev_arg="$__nerdline_tmp_ssh_arg"
		elif [[ $__nerdline_tmp_ssh_arg =~ ^-[A-Za-z0-9]* ]] && [[ -z $__nerdline_tmp_ssh_dest ]]
		then #completed argument
			if [[ -n $__nerdline_tmp_ssh_prev_arg ]]
			then
				error 15 "Invalid arg '$__nerdline_tmp_ssh_arg'"
			fi
			if [[ $__nerdline_tmp_ssh_arg == -t ]]
			then
				__nerdline_tmp_ssh_targ_exist=true
			fi
			__nerdline_tmp_ssh_parsed_args+=( "$__nerdline_tmp_ssh_arg" )
		else #destination
			if [[ -n $__nerdline_tmp_ssh_prev_arg ]]
			then
				__nerdline_tmp_ssh_parsed_args+=( "$__nerdline_tmp_ssh_prev_arg" "$__nerdline_tmp_ssh_arg" )
				__nerdline_tmp_ssh_prev_arg=
			else
				if [[ -n $__nerdline_tmp_ssh_dest ]]
				then
					__nerdline_tmp_ssh_dest_args+=( "$__nerdline_tmp_ssh_arg" )
				else
					__nerdline_tmp_ssh_dest="$__nerdline_tmp_ssh_arg"
				fi
			fi
		fi
	done
	if [[ -z $__nerdline_tmp_ssh_dest ]]
	then
		error 16 'Unknown destination'
	fi

	__nerdline_tmp_valnames=()
	for __nerdline_tmp_segment in ${__nerdline_segments}
	do
		eval __nerdline_tmp_valnames+='( "${!__nerdline_'"$__nerdline_tmp_segment"'_@}" )'
	done
	__nerdline_tmp_values=()
	for __nerdline_tmp_valname in "${__nerdline_tmp_valnames[@]}"
	do
		eval __nerdline_tmp_values+='( "'"$__nerdline_tmp_valname"'='"${!__nerdline_tmp_valname}"'" )'
	done
	__nerdline_tmp_values+=( "__nerdline_modules_ssh=\"${__nerdline_modules}\"" )
	__nerdline_tmp_values+=( "__nerdline_segments_ssh=\"${__nerdline_segments}\"" )

	if [[ ${#__nerdline_tmp_ssh_dest_args} -eq 0 ]]
	then
		if [[ -z $__nerdline_tmp_ssh_targ_exist ]]
		then
			__nerdline_tmp_ssh_parsed_args+=( '-t' )
		fi

		"$__nerdline_tmp_ssh_bin" "${__nerdline_tmp_ssh_parsed_args[@]}" "$__nerdline_tmp_ssh_dest" "$(
			for __nerdline_tmp_value in "${__nerdline_tmp_values[@]}"
			do
				echo "export $__nerdline_tmp_value"
			done
			for __nerdline_tmp_valname in "${!__nerdline_tarball@}"
			do
				echo "export '$__nerdline_tmp_valname=${!__nerdline_tmp_valname}'"
			done
			echo "export COLORTERM=truecolor
				if [[ -n \$XDG_DATA_HOME ]]
				then
					__nerdline_pfx=\"\$XDG_DATA_HOME/nerdline\"
				else
					__nerdline_pfx=\"\$HOME/.local/share/nerdline\"
				fi

				if [[ ! -d \"\$__nerdline_pfx\" ]]
				then
					mkdir -p \"\$__nerdline_pfx\" || exit 1
				fi
				if [[ ! -e \"\$__nerdline_pfx/sum\" ]] || [[ \$(cat \"\$__nerdline_pfx/sum\") != \$__nerdline_tarball_sum ]]
				then
					cd \"\$__nerdline_pfx/\" || exit 2
					echo \"\$__nerdline_tarball\" | base64 -d | tar -xJf - || exit 3
					echo -n \"$__nerdline_tarball_sum\" > ./sum
				fi
				cd ~/
				\"\$__nerdline_pfx/nerdline.sh\" test || exit 5
				bash --rcfile \"\$__nerdline_pfx/nerdline.sh\" ; exit $?"
		)"
	else
		"$__nerdline_tmp_ssh_bin" "${__nerdline_tmp_ssh_parsed_args[@]}" "$__nerdline_tmp_ssh_dest" "${__nerdline_tmp_ssh_dest_args[@]}"
	fi
	exit $?


##################################################################
elif [[ ${BASH_SOURCE[0]} != "$0" ]] #############################
then #Sourcing this file #########################################
	export __nerdline_mds_ssh_help='SSH module: transparent auto install nerdline and connect'
	alias ssh="nerdline ssh connect"


##################################################################
else #############################################################
	echo -e '\e[33;40musage: nerdline ssh <action>\n\e[0m'
	echo -e '\e[37;40mactions:\e[0m'
	echo -e '\e[36;40m\tconnect\t\tRun ssh connection\e[0m'
	echo -e '\e[36;40m\ttest\t\tConfiguration and integrity check\e[0m'
fi

