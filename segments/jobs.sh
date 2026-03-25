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
if [[ -z $__nerdline_jobs_color_fg ]]
then
	__nerdline_jobs_color_fg='#999'
fi
if [[ -z $__nerdline_jobs_color_bg ]]
then
	__nerdline_jobs_color_bg='#222'
fi
if [[ -z $__nerdline_jobs_color_running ]]
then
	__nerdline_jobs_color_running='#0f0'
fi
if [[ -z $__nerdline_jobs_color_stopped ]]
then
	__nerdline_jobs_color_stopped='#f00'
fi
if [[ -z $__nerdline_jobs_sign_running ]]
then
	__nerdline_jobs_sign_running='󱑠' #󰐊'
fi
if [[ -z $__nerdline_jobs_sign_stopped ]]
then
	__nerdline_jobs_sign_stopped='󱤳' #󰓛'
fi


##################################################################
if [[ $1 == test ]] ##############################################
then #Test (use it before sourcing file) #########################
	source "$__nerdline_pfx/lib/functions.sh" error

	if ! __nerdline_tmp_isColor "$__nerdline_jobs_color_fg"
	then
		error 1 "Invalid foreground color '$__nerdline_jobs_color_fg'"
	fi
	if ! __nerdline_tmp_isColor "$__nerdline_jobs_color_bg"
	then
		error 2 "Invalid background color '$__nerdline_jobs_color_bg'"
	fi


##################################################################
elif [[ ${BASH_SOURCE[0]} != "$0" ]] #############################
then #Sourcing this file #########################################
	#Convert colors to terminal format.
	__nerdline_tmp_parseColors "${!__nerdline_jobs_color_@}"
	export "${!__nerdline_jobs_@}"

	function __nerdline_jobs_update()
	{ #This function will be called on every update of the prompt
		local stopped=0
		local running=0
		local line
		while read -r line
		do
			if [[ $line =~ Stopped ]];then	((stopped+=1));fi
			if [[ $line =~ Running ]];then	((running+=1));fi
		done <<< "$(jobs 2>/dev/null)"

		unset __nerdline_jobs
		if [[ $running -gt 0 ]] || [[ $stopped -gt 0 ]]
		then
			__nerdline_jobs="${_nl_bg}${__nerdline_jobs_color_bg}${_nl_end}${_nl_fg}${__nerdline_jobs_color_fg}${_nl_end}"
		fi
		if [[ $running -gt 0 ]]
		then
			__nerdline_jobs+="${_nl_fg}${__nerdline_jobs_color_running}${_nl_end}${__nerdline_jobs_sign_running}${running} "
		fi
		if [[ $stopped -gt 0 ]]
		then
			__nerdline_jobs+="${_nl_fg}${__nerdline_jobs_color_stopped}${_nl_end}${__nerdline_jobs_sign_stopped}${stopped} "
		fi
	}
fi

