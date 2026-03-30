#!/bin/env bash

# Nerdline
# Copyright (C) 2026 Eduard Litovskikh (nicknames: Erfea, Yumi Cyannis; mail: erfea.tux at gmail)
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
if [[ ${1:-} == test ]] ##########################################
then #Test (use it before sourcing file) #########################
	function __nerdline_custom_test()
	{
		source "$__nerdline_pfx/lib/functions.sh" error

		# Validate prefix
		if [[ -z $__nerdline_pfx ]] || [[ ! -e "${__nerdline_pfx}/nerdline.sh" ]]
		then
			error 11 'Nerdline script is not found'
		fi

		# Validate enabled if defined
		if [[ -n ${__nerdline_custom_enabled:-} ]]; then
			case "${__nerdline_custom_enabled}" in
				0|1|true|false|yes|no|on|off) ;;
				*) error 12 "custom.enabled must be 0, 1 or boolean" ;;
			esac
		fi

		# Validate keybind format if defined
		# Value should be a valid bind argument (non-empty string)
		if [[ -n ${__nerdline_custom_keybind:-} ]]; then
			local __nerdline_cu_tmp
			while IFS= read -r __nerdline_cu_tmp; do
				[[ -z "$__nerdline_cu_tmp" ]] && continue
				# Must be non-empty
				if [[ -z "$__nerdline_cu_tmp" ]]; then
					error 13 "Invalid keybind format: empty value"
				fi
			done <<< "${__nerdline_custom_keybind//¶/$'\n'}"
		fi

		return 0
	}
	__nerdline_custom_test
	exit $?


##################################################################
elif [[ ${1:-} == run ]] #########################################
then #Run: apply keybindings ######################################
	__nerdline_custom_apply()
	{
		if [[ -z ${__nerdline_custom_keybind:-} ]]; then
			return 0
		fi

		local __nerdline_cu_tmp_binding
		while IFS= read -r __nerdline_cu_tmp_binding; do
			[[ -z "$__nerdline_cu_tmp_binding" ]] && continue
			bind "$__nerdline_cu_tmp_binding" 2>/dev/null || true
		done <<< "${__nerdline_custom_keybind//¶/$'\n'}"
	}

	__nerdline_custom_apply
	exit 0


##################################################################
elif [[ ${BASH_SOURCE[0]} != "$0" ]] #############################
then #Sourcing this file #########################################
	source "$__nerdline_pfx/lib/functions.sh" colors
	source "$__nerdline_pfx/lib/functions.sh" error-sourcing

	# Default enabled to 1 if not set
	if [[ -z ${__nerdline_custom_enabled:-} ]]; then
		__nerdline_custom_enabled=1
	fi

	# Apply keybindings on source if enabled
	__nerdline_custom_apply()
	{
		if [[ -z ${__nerdline_custom_keybind:-} ]]; then
			return 0
		fi

		local __nerdline_cu_tmp_binding
		while IFS= read -r __nerdline_cu_tmp_binding; do
			[[ -z "$__nerdline_cu_tmp_binding" ]] && continue
			bind "$__nerdline_cu_tmp_binding" 2>/dev/null || true
		done <<< "${__nerdline_custom_keybind//¶/$'\n'}"
	}

	if [[ "${__nerdline_custom_enabled}" -eq 1 ]]; then
		__nerdline_custom_apply
	fi

	export __nerdline_custom_keybind __nerdline_custom_enabled
	export __nerdline_mds_custom_help="Custom module: apply user keybindings"


##################################################################
else #############################################################
	echo -e '\e[33;40musage: nerdline custom <action>\n\e[0m'
	echo -e '\e[37;40mactions:\e[0m'
	echo -e '\e[36;40m\trun\t\tApply keybindings\e[0m'
	echo -e '\e[36;40m\ttest\t\tConfiguration and integrity check\e[0m'
fi