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

#Definition of undefined colors and signs
if [[ -z $__nerdline_user_color_fg ]]
then
	__nerdline_user_color_fg='#eee'
fi
if [[ -z $__nerdline_user_color_bg ]]
then
	__nerdline_user_color_bg='#010101'
fi
if [[ -z $__nerdline_user_color_user ]]
then
	__nerdline_user_color_user='#00f'
fi
if [[ -z $__nerdline_user_color_root ]]
then
	__nerdline_user_color_root='#f00'
fi
if [[ -z $__nerdline_user_sign_user ]]
then
	__nerdline_user_sign_user='󰀄 '
fi
if [[ -z $__nerdline_user_sign_root ]]
then
	__nerdline_user_sign_root='󰐣 '
fi
if [[ -z $__nerdline_user_sign_sudo ]]
then
	__nerdline_user_sign_sudo='󰀅 '
fi

##################################################################
if [[ $1 == test ]] ##############################################
then #Test (use it before sourcing file) #########################
	source "$__nerdline_pfx/lib/functions.sh" error

	if ! __nerdline_tmp_isColor "$__nerdline_user_color_fg"
	then
		error 1 "Invalid foreground color '$__nerdline_user_color_fg'"
	fi
	if ! __nerdline_tmp_isColor "$__nerdline_user_color_bg"
	then
		error 2 "Invalid background color '$__nerdline_user_color_bg'"
	fi
	if ! __nerdline_tmp_isColor "$__nerdline_user_color_user"
	then
		error 3 "Invalid user color '$__nerdline_user_color_user'"
	fi
	if ! __nerdline_tmp_isColor "$__nerdline_user_color_root"
	then
		error 4 "Invalid root color '$__nerdline_user_color_root'"
	fi
	if [[ ${#__nerdline_user_sign_user} -gt 3 ]]
	then
		error 5 'Invalid user sign'
	fi
	if [[ ${#__nerdline_user_sign_root} -gt 3 ]]
	then
		error 6 'Invalid root sign'
	fi


##################################################################
elif [[ ${BASH_SOURCE[0]} != "$0" ]] #############################
then #Sourcing this file #########################################
	#Convert colors to terminal format.
	__nerdline_tmp_parseColors "${!__nerdline_user_color_@}"
	export "${!__nerdline_user@}"

	if [[ $(id -u) -ne 0 ]]
	then #unprivileged user
		__nerdline_user="${_nl_bg}${__nerdline_user_color_bg}${_nl_end}${_nl_fg}${__nerdline_user_color_fg}${_nl_end}${__nerdline_user_sign_user}"
		__nerdline_user+="${_nl_fg}${__nerdline_user_color_user}${_nl_end}${USER}"
	elif [[ -n $SUDO_UID ]]
	then #sudo
		__nerdline_user="${_nl_bg}${__nerdline_user_color_bg}${_nl_end}${_nl_fg}${__nerdline_user_color_fg}${_nl_end}${__nerdline_user_sign_sudo}"
		__nerdline_user+="${_nl_fg}${__nerdline_user_color_root}${_nl_end}${SUDO_USER}"
	else #root
		__nerdline_user="${_nl_bg}${__nerdline_user_color_bg}${_nl_end}${_nl_fg}${__nerdline_user_color_fg}${_nl_end}${__nerdline_user_sign_root}"
		__nerdline_user+="${_nl_fg}${__nerdline_user_color_root}${_nl_end}${USER}"
	fi
fi

