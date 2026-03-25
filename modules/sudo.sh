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
	if [[ -z $__nerdline_pfx ]] || [[ ! -e "${__nerdline_pfx}/nerdline.sh" ]]
	then
		error 11 'Nerdline script is not found'
	fi


##################################################################
elif [[ $1 == run ]] #############################################
then #Run sudo command ###########################################
	source "$__nerdline_pfx/lib/functions.sh" error
	__nerdline_tmp_sudo_bin="$(which sudo)"
	"${__nerdline_tmp_sudo_bin}" -V > /dev/null 2>&1 || error 21 "Can't find sudo binary"
	__nerdline_tmp_sudo_args=( "$@" )
	__nerdline_tmp_sudo_args=( "${__nerdline_tmp_sudo_args[@]:1}" )

	if [[ ${#__nerdline_tmp_sudo_args} -eq 2 ]] && [[ ${__nerdline_tmp_sudo_args[0]} == su ]]
	then
		__nerdline_tmp_sudo_vals=
		for __nerdline_tmp_sudo_valname in "${!__nerdline_@}"
		do
			if [[ ! $__nerdline_tmp_sudo_valname =~ ^__nerdline_tmp ]]
			then
				if [[ -z $__nerdline_tmp_sudo_vals ]]
				then
					__nerdline_tmp_sudo_vals="--preserve-env=$__nerdline_tmp_sudo_valname"
				else
					__nerdline_tmp_sudo_vals+=",$__nerdline_tmp_sudo_valname"
				fi
			fi
		done
		"${__nerdline_tmp_sudo_bin}" "$__nerdline_tmp_sudo_vals" -- bash -rcfile "${__nerdline_pfx}/nerdline.sh"
	else
		"$__nerdline_tmp_sudo_bin" "${__nerdline_tmp_sudo_args[@]}"
	fi
	exit $?


##################################################################
elif [[ ${BASH_SOURCE[0]} != "$0" ]] #############################
then #Sourcing this file #########################################
	export __nerdline_mds_sudo_help="SUDO module: override 'sudo su' command to preload nerdline"
	alias sudo="nerdline sudo run"


##################################################################
else #############################################################
	echo -e '\e[33;40musage: nerdline sudo <action>\n\e[0m'
	echo -e '\e[37;40mactions:\e[0m'
	echo -e '\e[36;40m\trun\t\tRun sudo command\e[0m'
	echo -e '\e[36;40m\ttest\t\tConfiguration and integrity check\e[0m'
fi

