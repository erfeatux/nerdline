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
if [[ -z $__nerdline_hostname_color_fg ]]
then
	__nerdline_hostname_color_fg='#999'
fi
if [[ -z $__nerdline_hostname_color_bg ]]
then
	__nerdline_hostname_color_bg='#090909'
fi
if [[ -z $__nerdline_hostname_color_sign ]]
then
	__nerdline_hostname_color_sign="$__nerdline_hostname_color_fg"
fi
if [[ -z $__nerdline_hostname_color_sign_ssh ]]
then
	__nerdline_hostname_color_sign_ssh="#0f0"
fi
if [[ -z $__nerdline_hostname_showlocal ]]
then
	__nerdline_hostname_showlocal='false'
fi
if [[ -z $__nerdline_hostname_showip ]]
then
	__nerdline_hostname_showip='false'
fi
if [[ -z $__nerdline_hostname_sign ]]
then
	__nerdline_hostname_sign=' '
fi
if [[ -z $__nerdline_hostname_sign_ssh ]]
then
	__nerdline_hostname_sign_ssh='󱫋 '
fi


##################################################################
if [[ $1 == test ]] ##############################################
then #Test (use it before sourcing file) #########################
	source "$__nerdline_pfx/lib/functions.sh" error

	if ! __nerdline_tmp_isColor "$__nerdline_hostname_color_fg"
	then
		error 1 "Invalid foreground color '$__nerdline_hostname_color_fg'"
	fi
	if ! __nerdline_tmp_isColor "$__nerdline_hostname_color_bg"
	then
		error 2 "Invalid background color '$__nerdline_hostname_color_bg'"
	fi
	if ! __nerdline_tmp_isColor "$__nerdline_hostname_color_sign"
	then
		error 3 "Invalid sign color '$__nerdline_hostname_color_sign'"
	fi
	if ! __nerdline_tmp_isColor "$__nerdline_hostname_color_sign_ssh"
	then
		error 4 "Invalid ssh sign color '$__nerdline_hostname_color_sign_ssh'"
	fi
	if [[ ! ${__nerdline_hostname_showlocal,,} =~ ^(true|false|yes|no|1|0)$ ]]
	then
		error 5 "Invalid show local setting '$__nerdline_hostname_showlocal'"
	fi
	if [[ ! ${__nerdline_hostname_showip,,} =~ ^(true|false|yes|no|1|0)$ ]]
	then
		error 6 "Invalid show ip setting '$__nerdline_hostname_showip'"
	fi
	if [[ -z "$__nerdline_hostname_sign" ]] || [[ ${#__nerdline_hostname_sign} -gt 3 ]]
	then
		error 7 "Invalid hostname sign '$__nerdline_hostname_sign'"
	fi
	if [[ -z "$__nerdline_hostname_sign_ssh" ]] || [[ ${#__nerdline_hostname_sign_ssh} -gt 3 ]]
	then
		error 8 "Invalid ssh hostname sign '$__nerdline_hostname_sign_ssh'"
	fi


##################################################################
elif [[ ${BASH_SOURCE[0]} != "$0" ]] #############################
then #Sourcing this file #########################################
	#Convert colors to terminal format.
	__nerdline_tmp_parseColors "${!__nerdline_hostname_color_@}"
	export "${!__nerdline_hostname_@}"

	if ! command -v hostname &>/dev/null
	then
		__nerdline_hostname=""
		return
	fi

	if [[ -n $SSH_CLIENT ]]
	then
		__nerdline_tmp_hostname_sign="$__nerdline_hostname_sign_ssh"
		__nerdline_tmp_hostname_color_sign="$__nerdline_hostname_color_sign_ssh"
	else
		__nerdline_tmp_hostname_sign="$__nerdline_hostname_sign"
		__nerdline_tmp_hostname_color_sign="$__nerdline_hostname_color_sign"
	fi
	if [[ ${__nerdline_hostname_showip,,} =~ ^(true|yes|1)$ ]]
	then
		if command -v hostname &>/dev/null && hostname -I &>/dev/null
		then
			__nerdline_tmp_hostname="$(hostname -I | awk '{print $1}')"
		else
			__nerdline_tmp_hostname=""
		fi
	else
		__nerdline_tmp_hostname="$(hostname)"
	fi
	__nerdline_hostname="${_nl_bg}${__nerdline_hostname_color_bg}${_nl_end}${_nl_fg}${__nerdline_tmp_hostname_color_sign}${_nl_end}${__nerdline_tmp_hostname_sign}"
	if [[ ${__nerdline_hostname_showlocal,,} =~ ^(true|yes|1)$ ]] || [[ -n $SSH_CLIENT ]]
	then
		__nerdline_hostname+="${_nl_fg}${__nerdline_hostname_color_fg}${_nl_end}${__nerdline_tmp_hostname}"
	fi
fi

