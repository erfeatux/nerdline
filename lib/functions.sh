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

# shellcheck disable=SC1091,SC2001,SC2154

case $1 in
error-sourcing)
	function error
	{ #Return the specified error code and print message
		if [[ $# -eq 0 ]] || [[ $# -gt 2 ]]
		then
			echo -e "\e[31;40mInvalid function 'error' call ($# args)\e[0m"
			return 254
		fi
		if [[ ! $1 =~ ^[0-9]+$ ]] || [[ $1 -lt 1 ]] || [[ $1 -gt 253 ]]
		then
			echo -e "\e[31;40mInvalid function 'error' call ($1 - invalid error code)\e[0m"
			return 254
		fi
	
		if [[ $# -eq 1 ]] || [[ -z "$2" ]]
		then
			echo -e "\e[31;40mError code: $1\e[0m"
		else
			echo -e "\e[31;40m$2\e[0m\nError code: $1"
		fi
	
		unset error
		return "$1"
	}
	;;


error)
	function error
	{ #Exits with the specified error code and print message
		if [[ $# -eq 0 ]] || [[ $# -gt 2 ]]
		then
			echo -e "\e[31;40mInvalid function 'error' call ($# args)\e[0m"
			exit 254
		fi
		if [[ ! $1 =~ ^[0-9]+$ ]] || [[ $1 -lt 1 ]] || [[ $1 -gt 253 ]]
		then
			echo -e "\e[31;40mInvalid function 'error' call ($1 - invalid error code)\e[0m"
			exit 254
		fi
	
		if [[ $# -eq 1 ]] || [[ -z "$2" ]]
		then
			echo -e "\e[31;40mError code: $1\e[0m"
		else
			echo -e "\e[31;40m$2\e[0m"
		fi
	
		exit "$1"
	}
	;;


colors)
	function __nerdline_tmp_isColor()
	{ #Check if the first argument is a color
		local __nerdline_tmp_isColor_val="${1//,/:}"
		if [[ $__nerdline_tmp_isColor_val =~ ^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3}|[A-Fa-f0-9]{8})$ ]]
		then
			return 0
		elif [[ $__nerdline_tmp_isColor_val =~ ^([0-9]{1,3}:){2}[0-9]{1,3}$ ]]
		then
			local __nerdline_tmp_isColor_values
			IFS=':' read -ra __nerdline_tmp_isColor_values <<< "$__nerdline_tmp_isColor_val"
			if [[ ${__nerdline_tmp_isColor_values[0]} -lt 256 ]] && [[ ${__nerdline_tmp_isColor_values[1]} -lt 256 ]] && [[ ${__nerdline_tmp_isColor_values[2]} -lt 256 ]]
			then
				return 0
			else
				return 1
			fi
		fi
		return 1
	}
	
	function __nerdline_tmp_parseColors()
	{ #Converts variables to terminal format, arguments - variables names to be converted
		for __nerdline_tmp_parseColors_valname in "$@"
		do
			if ! __nerdline_tmp_isColor "${!__nerdline_tmp_parseColors_valname}"
			then #The variable should contain the valid color
				return 1
			fi
	
			__nerdline_tmp_parseColors_color="${!__nerdline_tmp_parseColors_valname}"
			if [[ $__nerdline_tmp_parseColors_color =~ ^#([A-Fa-f0-9]{3})$ ]]
			then #Expand short value
				local r="${__nerdline_tmp_parseColors_color:1:1}"
				local g="${__nerdline_tmp_parseColors_color:2:1}"
				local b="${__nerdline_tmp_parseColors_color:3:1}"
				__nerdline_tmp_parseColors_color="#${r}${r}${g}${g}${b}${b}"
			elif [[ $__nerdline_tmp_parseColors_color =~ ^#[A-Fa-f0-9]{8}$ ]]
			then #Delete alpha from color
				__nerdline_tmp_parseColors_color="${__nerdline_tmp_parseColors_color:0:7}"
			fi
	
			if [[ $__nerdline_tmp_parseColors_color =~ ^#[A-Fa-f0-9]{6}$ ]]
			then #From hex
				__nerdline_tmp_parseColors_eval="$((16#${__nerdline_tmp_parseColors_color:1:2}))"
				__nerdline_tmp_parseColors_eval+=":$((16#${__nerdline_tmp_parseColors_color:3:2}))"
				__nerdline_tmp_parseColors_eval+=":$((16#${__nerdline_tmp_parseColors_color:5:2}))"
				printf -v "$__nerdline_tmp_parseColors_valname" '%s' "$__nerdline_tmp_parseColors_eval"
			else #From decimal digits
				printf -v "$__nerdline_tmp_parseColors_valname" '%s' "${__nerdline_tmp_parseColors_color//,/:}"
			fi
		done
		return 0
	}
	;;


config)
	function __nerdline_tmp_load_config()
	{
		local __nerdline_tmp_cfg_file="$1"
		#############################
		# local __nerdline_tmp_cfg_pfx="$2"
	
		if [[ ! -r "$__nerdline_tmp_cfg_file" ]]
		then
			error 10 "Can't read config file '$__nerdline_tmp_cfg_file'";return $?
		fi
	
		local __nerdline_tmp_cfg_section=
		while read -r __nerdline_tmp_line
		do
			if [[ -z "$__nerdline_tmp_line" ]] || [[ "$__nerdline_tmp_line" =~ ^\s*# ]]
			then
				continue
			fi
	
			if [[ $__nerdline_tmp_line =~ ^\[.*\]$ ]]
			then #Defined section
				local __nerdline_tmp_cfg_section_raw="${__nerdline_tmp_line:1:-1}"
				__nerdline_tmp_cfg_section="${__nerdline_tmp_cfg_section_raw#"${__nerdline_tmp_cfg_section_raw%%[![:space:]]*}"}"
				__nerdline_tmp_cfg_section="${__nerdline_tmp_cfg_section%"${__nerdline_tmp_cfg_section##*[![:space:]]}"}"
				continue
			fi
	
			#else try parse entry
			local __nerdline_tmp_cfg_key_raw="${__nerdline_tmp_line%%=*}"
			local __nerdline_tmp_cfg_val_raw="${__nerdline_tmp_line#*=}"
			local __nerdline_tmp_cfg_key="${__nerdline_tmp_cfg_key_raw#"${__nerdline_tmp_cfg_key_raw%%[![:space:]]*}"}"
			__nerdline_tmp_cfg_key="${__nerdline_tmp_cfg_key%"${__nerdline_tmp_cfg_key##*[![:space:]]}"}"
			local __nerdline_tmp_cfg_val="${__nerdline_tmp_cfg_val_raw#"${__nerdline_tmp_cfg_val_raw%%[![:space:]]*}"}"
			__nerdline_tmp_cfg_val="${__nerdline_tmp_cfg_val%"${__nerdline_tmp_cfg_val##*[![:space:]]}"}"
			if [[ ${#__nerdline_tmp_cfg_val} -ge 2 ]];
			then
				local __nerdline__q1="${__nerdline_tmp_cfg_val:0:1}"
				local __nerdline__q2="${__nerdline_tmp_cfg_val: -1}"
				if [[ "$__nerdline__q1" == "$__nerdline__q2" && ( "$__nerdline__q1" == '"' || "$__nerdline__q1" == "'" ) ]]
				then
					__nerdline_tmp_cfg_val="${__nerdline_tmp_cfg_val:1:-1}"
				fi
			fi

			if [[ -z $__nerdline_tmp_cfg_key ]] || [[ -z $__nerdline_tmp_cfg_val ]] || [[ ! $__nerdline_tmp_line =~ = ]]
			then
				error 11 "Invalid entry '$__nerdline_tmp_line' in '$__nerdline_tmp_cfg_section' section";return $?
			fi
	
			#make bash value from parsed entry
			local __nerdline_tmp_valname="__nerdline_"
			if [[ ${__nerdline_tmp_cfg_section,,} != nerdline ]]
			then
				__nerdline_tmp_valname+="${__nerdline_tmp_cfg_section,,}_"
			fi
			__nerdline_tmp_valname+="${__nerdline_tmp_cfg_key//./_}"
			# Support multiple values with same key (append with ¶) for specific multi-value keys
			# These keys are intentionally multi-value: keybind
			local __nerdline_tmp_is_multi=false
			case "$__nerdline_tmp_valname" in
				*_keybind) __nerdline_tmp_is_multi=true ;;
			esac
			if [[ "$__nerdline_tmp_is_multi" == true ]] && [[ -n "${!__nerdline_tmp_valname}" ]]; then
				printf -v "$__nerdline_tmp_valname" '%s' "${!__nerdline_tmp_valname}¶$__nerdline_tmp_cfg_val"
			else
				printf -v "$__nerdline_tmp_valname" '%s' "$__nerdline_tmp_cfg_val"
			fi
		done < "$__nerdline_tmp_cfg_file"

		# Default short_pwd to true if not set in any section
		if [[ -z ${__nerdline_win_title_short_pwd:-} ]]
		then
			__nerdline_win_title_short_pwd=true
		fi
	}
	;;


nerdline)
	function nerdline()
	{ #nerdline command
		if [[ $1 == 'update' ]]
		then
			if [[ $2 == -f ]] || [[ $2 == --force ]]
			then
				_nl_tmp="$__nerdline_pfx"
				unset "${!__nerdline@}"
				export __nerdline_pfx="$_nl_tmp"
				unset _nl_tmp
			fi
			"${__nerdline_pfx}/nerdline.sh" test && source "${__nerdline_pfx}/nerdline.sh" && echo -e '\e[32;40;1mOk\e[0m'
		else
			"${__nerdline_pfx}/nerdline.sh" "$@"
		fi
	}

	function __nerdline_update()
	{ #Update prompt
		_nl_bg='\[\e[48:2::'
		_nl_fg='\[\e[38:2::'
		_nl_end='m\]'
		_nl_clr='\[\e[m\]'

		PS1=''
		for __nerdline_tmp_segment in ${__nerdline_segments}
		do
			__nerdline_tmp_ps1=
			__nerdline_tmp_bg="__nerdline_${__nerdline_tmp_segment}_color_bg"
			__nerdline_tmp_fg="__nerdline_${__nerdline_tmp_segment}_color_fg"
			if [[ -n $__nerdline_tmp_prev_bg ]]
			then #Not first segment
				if [[ "${!__nerdline_tmp_bg}" != "${!__nerdline_tmp_prev_bg}" ]]
				then #previous segment has a different background color
					__nerdline_tmp_ps1+="${_nl_bg}${!__nerdline_tmp_bg}${_nl_end}${_nl_fg}${!__nerdline_tmp_prev_bg}${_nl_end}${__nerdline_separator}${_nl_clr}"
				else
					if [[ -n $__nerdline_separator_color ]]
					then #Custom separator color is defined
						__nerdline_tmp_ps1+="${_nl_bg}${!__nerdline_tmp_bg}${_nl_end}${_nl_fg}${__nerdline_separator_color}${_nl_end}${__nerdline_separator_same_bg}${_nl_clr}"
					else
						__nerdline_tmp_ps1+="${_nl_bg}${!__nerdline_tmp_bg}${_nl_end}${_nl_fg}${!__nerdline_tmp_fg}${_nl_end}${__nerdline_separator_same_bg}${_nl_clr}"
					fi
				fi
			else
				__nerdline_tmp_ps1+="${_nl_bg}${!__nerdline_tmp_bg}${_nl_end} "
			fi

			if [[ $(type -t "__nerdline_${__nerdline_tmp_segment}_update") == function ]]
			then #Update function for the current segment is defined
				"__nerdline_${__nerdline_tmp_segment}_update"
			fi
			__nerdline_tmp_valname="__nerdline_${__nerdline_tmp_segment}"
			if [[ -n ${!__nerdline_tmp_valname} ]]
			then
				__nerdline_tmp_ps1+="${!__nerdline_tmp_valname}"
				PS1+="${__nerdline_tmp_ps1% } ${_nl_clr}"
				__nerdline_tmp_prev_bg="$__nerdline_tmp_bg"
			fi
		done
		if [[ -n $__nerdline_tmp_prev_bg ]]
		then #Last separator
			PS1+="${_nl_bg}${__nerdline_term_bg}${_nl_end}${_nl_fg}${!__nerdline_tmp_prev_bg}${_nl_end}${__nerdline_separator}${_nl_clr}"
		fi
		# if [[ -z $__nerdline_prompt_symbol ]]
		# then
		# 	__nerdline_prompt_symbol=' '
		# fi
		# PS1+="$__nerdline_prompt_symbol"
		unset "${!_nl_@}"
		unset "${!__nerdline_tmp_@}"
		if [[ -n "${!__nerdline_mds_@}" ]]
		then
			export "${!__nerdline_mds_@}"
		fi
	}
	;;
esac
