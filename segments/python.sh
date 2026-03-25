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
if [[ -z $__nerdline_python_color_fg ]]
then
	__nerdline_python_color_fg='#00ff00'
fi
if [[ -z $__nerdline_python_color_bg ]]
then
	__nerdline_python_color_bg='#090909'
fi
if [[ -z $__nerdline_python_color_sign ]]
then
	__nerdline_python_color_sign="$__nerdline_python_color_fg"
fi
if [[ -z $__nerdline_python_color_sign_conda ]]
then
	__nerdline_python_color_sign_conda="$__nerdline_python_color_sign"
fi
if [[ -z $__nerdline_python_sign ]]
then
	__nerdline_python_sign='󰌠 '
fi
if [[ -z $__nerdline_python_sign_conda ]]
then
	__nerdline_python_sign_conda='󱔎 '
fi

##################################################################
if [[ $1 == test ]] ##############################################
then #Test (use it before sourcing file) #########################
	source "$__nerdline_pfx/lib/functions.sh" error

	if ! __nerdline_tmp_isColor "$__nerdline_python_color_fg"
	then
		error 1 "Invalid foreground color '$__nerdline_python_color_fg'"
	fi
	if ! __nerdline_tmp_isColor "$__nerdline_python_color_bg"
	then
		error 2 "Invalid background color '$__nerdline_python_color_bg'"
	fi
	if ! __nerdline_tmp_isColor "$__nerdline_python_color_sign"
	then
		error 3 "Invalid sign color '$__nerdline_python_color_sign'"
	fi
	if ! __nerdline_tmp_isColor "$__nerdline_python_color_sign_conda"
	then
		error 4 "Invalid conda sign color '$__nerdline_python_color_sign_conda'"
	fi
	if [[ -z "$__nerdline_python_sign" ]] || [[ ${#__nerdline_python_sign} -gt 3 ]]
	then
		error 5 "Invalid sign '$__nerdline_python_sign'"
	fi
	if [[ -z "$__nerdline_python_sign_conda" ]] || [[ ${#__nerdline_python_sign_conda} -gt 3 ]]
	then
		error 6 "Invalid conda sign '$__nerdline_python_sign_conda'"
	fi


##################################################################
elif [[ ${BASH_SOURCE[0]} != "$0" ]] #############################
then #Sourcing this file #########################################
	#Convert colors to terminal format.
	__nerdline_tmp_parseColors "${!__nerdline_python_color_@}"
	export "${!__nerdline_python_@}"

	function __nerdline_python_update()
	{ #This function will be called on every update of the prompt
		if ! command -v python &>/dev/null
		then
			unset __nerdline_python
			return
		fi

		if [[ -n $VIRTUAL_ENV_PROMPT ]]
		then
			__nerdline_python="${_nl_bg}${__nerdline_python_color_bg}${_nl_end}${_nl_fg}${__nerdline_python_color_sign}${_nl_end}${__nerdline_python_sign}"
			__nerdline_python+="${_nl_fg}${__nerdline_python_color_fg}${_nl_end}$(python -V | sed 's/^\w*\s*//') ${VIRTUAL_ENV_PROMPT}"
		elif [[ -n $CONDA_PROMPT_MODIFIER ]]
		then
			__nerdline_python="${_nl_bg}${__nerdline_python_color_bg}${_nl_end}${_nl_fg}${__nerdline_python_color_sign_conda}${_nl_end}${__nerdline_python_sign_conda}"
			__nerdline_python+="${_nl_fg}${__nerdline_python_color_fg}${_nl_end}$(python -V | sed 's/^\w*\s*//') ${CONDA_PROMPT_MODIFIER}"
		else
			unset __nerdline_python
		fi
	}
fi

