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

# shellcheck disable=SC1091,SC2001,SC2154

__nerdline_pfx="/home/erfea/Projects/nerdline"

source "$__nerdline_pfx/tests/test_lib.sh"

function test_custom_enabled_values()
{
	local test_config_file="/tmp/nerdline_test_custom_$$.cfg"
	local exit_code

	# Valid values: 0, 1, true, false, yes, no, on, off
	for val in 0 1 true false yes no on off; do
		cat > "$test_config_file" <<< "[custom]
enabled = $val"
		local output
		output="$(bash -c "
			source '$__nerdline_pfx/lib/functions.sh' error-sourcing
			source '$__nerdline_pfx/lib/functions.sh' config
			__nerdline_tmp_load_config '$test_config_file'
			source '$__nerdline_pfx/modules/custom.sh' test 2>&1
		")"
		# If error message appears, test failed
		if [[ "$output" == *"Error code"* ]] || [[ "$output" == *"Invalid"* ]]; then
			nerdline_test_assert "custom.enabled=$val is valid" "0" "1"
			echo "  Output: $output"
		else
			nerdline_test_assert "custom.enabled=$val is valid" "0" "0"
		fi
	done

	rm -f "$test_config_file"
}

function test_custom_invalid_enabled()
{
	local test_config_file="/tmp/nerdline_test_custom_$$.cfg"
	cat > "$test_config_file" <<< "[custom]
enabled = invalid"
	
	local output
	output="$(bash -c "
		source '$__nerdline_pfx/lib/functions.sh' error-sourcing
		source '$__nerdline_pfx/lib/functions.sh' config
		__nerdline_tmp_load_config '$test_config_file'
		source '$__nerdline_pfx/modules/custom.sh' test 2>&1
	")"
	
	rm -f "$test_config_file"
	
	# Check if error message appears in output
	if [[ "$output" == *"custom.enabled must be"* ]]; then
		nerdline_test_assert "custom.enabled=invalid fails" "0" "0"
	else
		nerdline_test_assert "custom.enabled=invalid fails" "0" "1"
		echo "  Output: $output"
	fi
}

function test_custom_valid_keybind()
{
	local test_config_file="/tmp/nerdline_test_custom_$$.cfg"
	cat > "$test_config_file" <<< "[custom]
keybind = \"set completion-ignore-case on\""
	
	local output
	output="$(bash -c "
		source '$__nerdline_pfx/lib/functions.sh' error-sourcing
		source '$__nerdline_pfx/lib/functions.sh' config
		__nerdline_tmp_load_config '$test_config_file'
		source '$__nerdline_pfx/modules/custom.sh' test 2>&1
	")"
	
	rm -f "$test_config_file"
	
	# Check that no error message appears
	if [[ "$output" == *"Error code"* ]] || [[ "$output" == *"Invalid"* ]]; then
		nerdline_test_assert "Valid keybind passes test" "0" "1"
		echo "  Output: $output"
	else
		nerdline_test_assert "Valid keybind passes test" "0" "0"
	fi
}

function test_custom_multiple_keybinds()
{
	local test_config_file="/tmp/nerdline_test_custom_$$.cfg"
	cat > "$test_config_file" <<< "[custom]
keybind = '\"\\C-r\": reverse-search-history'
keybind = '\"\\C-l\": clear-screen'"
	
	local output
	output="$(bash -c "
		source '$__nerdline_pfx/lib/functions.sh' error-sourcing
		source '$__nerdline_pfx/lib/functions.sh' config
		__nerdline_tmp_load_config '$test_config_file'
		source '$__nerdline_pfx/modules/custom.sh' test 2>&1
	")"
	
	rm -f "$test_config_file"
	
	# Check that no error message appears
	if [[ "$output" == *"Invalid"* ]]; then
		nerdline_test_assert "Multiple keybinds pass test" "0" "1"
		echo "  Error in output: $output"
	else
		nerdline_test_assert "Multiple keybinds pass test" "0" "0"
	fi
}

function test_custom_apply()
{
	# Skip in non-interactive shells (bind doesn't work)
	if [[ ! -t 0 ]] || [[ $- != *i* ]]; then
		nerdline_test_assert "custom apply skipped (non-interactive)" "skip" "skip"
		return 0
	fi
	
	local test_config_file="/tmp/nerdline_test_custom_$$.cfg"
	cat > "$test_config_file" <<< "[custom]
keybind = \"set completion-ignore-case on\""
	
	bash -c "
		source '$__nerdline_pfx/lib/functions.sh' error-sourcing
		source '$__nerdline_pfx/lib/functions.sh' config
		__nerdline_tmp_load_config '$test_config_file'
		source '$__nerdline_pfx/modules/custom.sh' run
		bind -L | grep -q completion-ignore-case
	" 2>&1
	
	local result=$?
	rm -f "$test_config_file"
	
	nerdline_test_assert "custom run applies keybindings" "0" "$result"
}

__nerdline_test_init

nerdline_test_run "Custom enabled values" test_custom_enabled_values
nerdline_test_run "Custom invalid enabled" test_custom_invalid_enabled
nerdline_test_run "Custom valid keybind" test_custom_valid_keybind
nerdline_test_run "Custom multiple keybinds" test_custom_multiple_keybinds
nerdline_test_run "Custom apply keybindings" test_custom_apply

__nerdline_test_summary