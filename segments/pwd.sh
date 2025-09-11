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

source "$__nerdline_pfx/lib/functions.sh" colors

#Definition of undefined colors and vars
if [[ -z $__nerdline_pwd_color_fg ]]
then
	__nerdline_pwd_color_fg='#999'
fi
if [[ -z $__nerdline_pwd_color_bg ]]
then
	__nerdline_pwd_color_bg='#090909'
fi
if [[ -z $__nerdline_pwd_color_sign ]]
then
	__nerdline_pwd_color_sign='#eee'
fi
if [[ -z $__nerdline_pwd_home_sign ]]
then
	__nerdline_pwd_home_sign=''
fi


##################################################################
if [[ $1 == test ]] ##############################################
then #Test (use it before sourcing file) #########################
	source "$__nerdline_pfx/lib/functions.sh" error

	if ! __nerdline_tmp_isColor "$__nerdline_pwd_color_fg"
	then
		error 1 "Invalid foreground color '$__nerdline_pwd_color_fg'"
	fi
	if ! __nerdline_tmp_isColor "$__nerdline_pwd_color_bg"
	then
		error 2 "Invalid background color '$__nerdline_pwd_color_bg'"
	fi
	if ! __nerdline_tmp_isColor "$__nerdline_pwd_color_sign"
	then
		error 3 "Invalid sign color '$__nerdline_pwd_color_sign'"
	fi
	if [[ -z "$__nerdline_pwd_home_sign" ]] || [[ ${#__nerdline_pwd_home_sign} -gt 3 ]]
	then
		error 4 "Invalid sign '$__nerdline_pwd_home_sign'"
	fi


##################################################################
elif [[ ${BASH_SOURCE[0]} != "$0" ]] #############################
then #Sourcing this file #########################################
	#Convert colors to terminal format.
	__nerdline_tmp_parseColors "${!__nerdline_pwd_color_@}"
	export "${!__nerdline_pwd@}"

	function __nerdline_pwd_update()
	{ #This function will be called on every update of the prompt
		if [[ $PWD =~ ^$HOME ]]
		then
			__nerdline_pwd="${_nl_bg}${__nerdline_pwd_color_bg}${_nl_end}${_nl_fg}${__nerdline_pwd_color_sign}${_nl_end}${__nerdline_pwd_home_sign}"
			__nerdline_pwd+="${_nl_fg}${__nerdline_pwd_color_fg}${_nl_end}${PWD/$HOME/}"
		else
			__nerdline_pwd="${_nl_bg}${__nerdline_pwd_color_bg}${_nl_end}${_nl_fg}${__nerdline_pwd_color_fg}${_nl_end}${PWD}"
		fi
	}
fi

