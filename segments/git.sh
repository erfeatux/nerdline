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
if [[ -z $__nerdline_git_color_fg ]]
then
	__nerdline_git_color_fg='#00ff00'
fi
if [[ -z $__nerdline_git_color_bg ]]
then
	__nerdline_git_color_bg='#090909'
fi
if [[ -z $__nerdline_git_color_sign ]]
then
	__nerdline_git_color_sign="$__nerdline_git_color_fg"
fi
if [[ -z $__nerdline_git_color_add ]]
then
	__nerdline_git_color_add='#0f0'
fi
if [[ -z $__nerdline_git_color_ignore ]]
then
	__nerdline_git_color_ignore='#888'
fi
if [[ -z $__nerdline_git_color_mod ]]
then
	__nerdline_git_color_mod='#fa0'
fi
if [[ -z $__nerdline_git_color_rm ]]
then
	__nerdline_git_color_rm='#f00'
fi
if [[ -z $__nerdline_git_color_rn ]]
then
	__nerdline_git_color_rn='#00f'
fi
if [[ -z $__nerdline_git_sign_branch ]]
then
	__nerdline_git_sign_branch=''
fi
if [[ -z $__nerdline_git_sign_add ]]
then
	__nerdline_git_sign_add=''
fi
if [[ -z $__nerdline_git_sign_ignore ]]
then
	__nerdline_git_sign_ignore=''
fi
if [[ -z $__nerdline_git_sign_mod ]]
then
	__nerdline_git_sign_mod=''
fi
if [[ -z $__nerdline_git_sign_rm ]]
then
	__nerdline_git_sign_rm=''
fi
if [[ -z $__nerdline_git_sign_rn ]]
then
	__nerdline_git_sign_rn=''
fi

##################################################################
if [[ $1 == test ]] ##############################################
then #Test (use it before sourcing file) #########################
	source "$__nerdline_pfx/lib/functions.sh" error

	if ! __nerdline_tmp_isColor "$__nerdline_git_color_fg"
	then
		error 1 "Invalid foreground color '$__nerdline_git_color_fg'"
	fi
	if ! __nerdline_tmp_isColor "$__nerdline_git_color_bg"
	then
		error 2 "Invalid background color '$__nerdline_git_color_bg'"
	fi
	if ! __nerdline_tmp_isColor "$__nerdline_git_color_sign"
	then
		error 3 "Invalid branch sign color '$__nerdline_git_color_sign'"
	fi
	if ! __nerdline_tmp_isColor "$__nerdline_git_color_add"
	then
		error 4 "Invalid added color '$__nerdline_git_color_add'"
	fi
	if ! __nerdline_tmp_isColor "$__nerdline_git_color_ignore"
	then
		error 5 "Invalid ignored color '$__nerdline_git_color_ignore'"
	fi
	if ! __nerdline_tmp_isColor "$__nerdline_git_color_mod"
	then
		error 6 "Invalid modified color '$__nerdline_git_color_mod'"
	fi
	if ! __nerdline_tmp_isColor "$__nerdline_git_color_rm"
	then
		error 7 "Invalid removed color '$__nerdline_git_color_rm'"
	fi
	if ! __nerdline_tmp_isColor "$__nerdline_git_color_rn"
	then
		error 8 "Invalid renamed color '$__nerdline_git_color_rn'"
	fi
	if [[ -z "$__nerdline_git_sign_branch" ]] || [[ ${#__nerdline_git_sign_branch} -gt 3 ]]
	then
		error 9 "Invalid branch sign '$__nerdline_git_sign_branch'"
	fi
	if [[ -z "$__nerdline_git_sign_add" ]] || [[ ${#__nerdline_git_sign_add} -gt 3 ]]
	then
		error 10 "Invalid added sign '$__nerdline_git_sign_add'"
	fi
	if [[ -z "$__nerdline_git_sign_ignore" ]] || [[ ${#__nerdline_git_sign_ignore} -gt 3 ]]
	then
		error 11 "Invalid ignore sign '$__nerdline_git_sign_ignore'"
	fi
	if [[ -z "$__nerdline_git_sign_mod" ]] || [[ ${#__nerdline_git_sign_mod} -gt 3 ]]
	then
		error 12 "Invalid modified sign '$__nerdline_git_sign_mod'"
	fi
	if [[ -z "$__nerdline_git_sign_rm" ]] || [[ ${#__nerdline_git_sign_rm} -gt 3 ]]
	then
		error 13 "Invalid removed sign '$__nerdline_git_sign_rm'"
	fi
	if [[ -z "$__nerdline_git_sign_rn" ]] || [[ ${#__nerdline_git_sign_rn} -gt 3 ]]
	then
		error 14 "Invalid renamed sign '$__nerdline_git_sign_rn'"
	fi


##################################################################
elif [[ ${BASH_SOURCE[0]} != "$0" ]] #############################
then #Sourcing this file #########################################
	#Convert colors to terminal format.
	__nerdline_tmp_parseColors "${!__nerdline_git_color_@}"
	export "${!__nerdline_git_@}"

	function __nerdline_git_update()
	{ #This function will be called on every update of the prompt
		local branch
		local add=0
		local ignored=0
		local mod=0
		local rm=0
		local rn=0
		local line action
		while read -r line
		do
			if [[ -z $branch ]] && [[ $line =~ ^## ]]
			then
				branch="${line#\#\# }"
				branch="${branch/...*}"
				continue
			fi
			action="${line%% *}"
			if [[ $action =~ A ]];then		(( add+=1 ))
			elif [[ $action =~ \? ]];then	(( ignored++ ))
			elif [[ $action =~ M ]];then	(( mod++ ))
			elif [[ $action =~ D ]];then	(( rm++ ))
			elif [[ $action =~ R ]];then	(( rn++ ))
			fi
		done <<< "$(git status --porcelain=v1 -b)"
		unset __nerdline_git
		if [[ -n $branch ]]
		then
			__nerdline_git="${_nl_bg}${__nerdline_git_color_bg}${_nl_end}${_nl_fg}${__nerdline_git_color_fg}${_nl_end}${__nerdline_git_sign_branch} ${branch}"
			if [[ $add -gt 0 ]]
			then
				__nerdline_git+=" ${_nl_fg}${__nerdline_git_color_add}${_nl_end}${__nerdline_git_sign_add}${add}"
			fi
			if [[ $rm -gt 0 ]]
			then
				__nerdline_git+=" ${_nl_fg}${__nerdline_git_color_rm}${_nl_end}${__nerdline_git_sign_rm}${rm}"
			fi
			if [[ $mod -gt 0 ]]
			then
				__nerdline_git+=" ${_nl_fg}${__nerdline_git_color_mod}${_nl_end}${__nerdline_git_sign_mod}${mod}"
			fi
			if [[ $rn -gt 0 ]]
			then
				__nerdline_git+=" ${_nl_fg}${__nerdline_git_color_rn}${_nl_end}${__nerdline_git_sign_rn}${rn}"
			fi
			if [[ $ignored -gt 0 ]]
			then
				__nerdline_git+=" ${_nl_fg}${__nerdline_git_color_ignore}${_nl_end}${__nerdline_git_sign_ignore}${ignored}"
			fi
		fi
	}
fi

