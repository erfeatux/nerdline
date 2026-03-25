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

function test_segment()
{
	local segment_name="$1"
	local segment_file="$__nerdline_pfx/segments/${segment_name}.sh"

	if [[ ! -f "$segment_file" ]]; then
		nerdline_test_assert "Segment $segment_name exists" 1 0
		return
	fi

	echo "Testing segment: $segment_name"

	local output
	output="$(TERMSHELL=bash __nerdline_pfx="$__nerdline_pfx" bash -c "source $segment_file test" 2>&1; echo "exit:$?")"

	local exit_code
	exit_code="$(echo "$output" | tail -1 | cut -d: -f2)"

	if [[ "$exit_code" == "0" ]]; then
		nerdline_test_assert "Segment $segment_name test passed" 0 0
	else
		nerdline_test_assert "Segment $segment_name test passed" 0 1
		echo "  Output: $output"
	fi
}

__nerdline_test_init

for segment in user hostname python hist git pwd jobs retcode example; do
	test_segment "$segment"
done

__nerdline_test_summary