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
source "$__nerdline_pfx/lib/functions.sh" error-sourcing

function test_error_sourcing_valid_codes()
{
	local output
	output="$(error 1 'test error 1' 2>&1; echo "exit:$?")"
	nerdline_test_assert "Error code 1 returns 1" "1" "$(echo "$output" | tail -1 | cut -d: -f2)"

	output="$(error 10 'test error 10' 2>&1; echo "exit:$?")"
	nerdline_test_assert "Error code 10 returns 10" "10" "$(echo "$output" | tail -1 | cut -d: -f2)"

	output="$(error 253 'test error 253' 2>&1; echo "exit:$?")"
	nerdline_test_assert "Error code 253 returns 253" "253" "$(echo "$output" | tail -1 | cut -d: -f2)"
}

function test_error_sourcing_reserved_code()
{
	local output
	output="$(error 254 'reserved code' 2>&1; echo "exit:$?")"
	nerdline_test_assert "Reserved code 254 returns 254" "254" "$(echo "$output" | tail -1 | cut -d: -f2)"
}

function test_error_sourcing_too_many_args()
{
	local output
	output="$(error 1 2 3 2>&1; echo "exit:$?")"
	nerdline_test_assert "Too many args returns 254" "254" "$(echo "$output" | tail -1 | cut -d: -f2)"
}

function test_error_sourcing_no_args()
{
	local output
	output="$(error 2>&1; echo "exit:$?")"
	nerdline_test_assert "No args returns 254" "254" "$(echo "$output" | tail -1 | cut -d: -f2)"
}

function test_error_sourcing_invalid_code()
{
	local output
	output="$(error 0 'invalid code' 2>&1; echo "exit:$?")"
	nerdline_test_assert "Code 0 returns 254" "254" "$(echo "$output" | tail -1 | cut -d: -f2)"

	output="$(error 255 'invalid code' 2>&1; echo "exit:$?")"
	nerdline_test_assert "Code 255 returns 254" "254" "$(echo "$output" | tail -1 | cut -d: -f2)"

	output="$(error -1 'negative code' 2>&1; echo "exit:$?")"
	nerdline_test_assert "Negative code returns 254" "254" "$(echo "$output" | tail -1 | cut -d: -f2)"

	output="$(error abc 'non-numeric' 2>&1; echo "exit:$?")"
	nerdline_test_assert "Non-numeric code returns 254" "254" "$(echo "$output" | tail -1 | cut -d: -f2)"
}

function test_error_sourcing_message_output()
{
	local output
	output="$(error 5 'my test error message' 2>&1)"
	nerdline_test_assert_ne "Error message printed to stderr" "" "$output"
	nerdline_test_assert_ne "Error message contains text" "my test error message" "$output"
}

function test_error_sourcing_empty_message()
{
	local output
	output="$(error 5 2>&1; echo "exit:$?")"
	nerdline_test_assert "Empty message only prints code" "5" "$(echo "$output" | tail -1 | cut -d: -f2)"
}

__nerdline_test_init

nerdline_test_run "Valid Error Codes" test_error_sourcing_valid_codes
nerdline_test_run "Reserved Code" test_error_sourcing_reserved_code
nerdline_test_run "Too Many Args" test_error_sourcing_too_many_args
nerdline_test_run "No Args" test_error_sourcing_no_args
nerdline_test_run "Invalid Error Code" test_error_sourcing_invalid_code
nerdline_test_run "Message Output" test_error_sourcing_message_output
nerdline_test_run "Empty Message" test_error_sourcing_empty_message

__nerdline_test_summary