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

######################################################################
# Test counters
######################################################################
__nerdline_test_passed=0
__nerdline_test_failed=0
__nerdline_test_total=0

######################################################################
# Colors for output
######################################################################
__nerdline_test_clr_pass='\033[0;32m'
__nerdline_test_clr_fail='\033[0;31m'
__nerdline_test_clr_reset='\033[0m'

function __nerdline_test_init()
{
	__nerdline_test_passed=0
	__nerdline_test_failed=0
	__nerdline_test_total=0
}

function nerdline_test_assert()
{
	local description="$1"
	local expected="$2"
	local actual="$3"

	((__nerdline_test_total++))

	if [[ "$expected" == "$actual" ]]; then
		((__nerdline_test_passed++))
		echo -e "${__nerdline_test_clr_pass}✓${__nerdline_test_clr_reset} $description"
		return 0
	else
		((__nerdline_test_failed++))
		echo -e "${__nerdline_test_clr_fail}✗${__nerdline_test_clr_reset} $description"
		echo "  Expected: '$expected'"
		echo "  Actual:   '$actual'"
		return 1
	fi
}

function nerdline_test_assert_ne()
{
	local description="$1"
	local not_expected="$2"
	local actual="$3"

	((__nerdline_test_total++))

	if [[ "$not_expected" != "$actual" ]]; then
		((__nerdline_test_passed++))
		echo -e "${__nerdline_test_clr_pass}✓${__nerdline_test_clr_reset} $description"
		return 0
	else
		((__nerdline_test_failed++))
		echo -e "${__nerdline_test_clr_fail}✗${__nerdline_test_clr_reset} $description"
		echo "  Not expected: '$not_expected'"
		echo "  Actual:        '$actual'"
		return 1
	fi
}

function nerdline_test_assert_exit_code()
{
	local description="$1"
	local expected_code="$2"
	local cmd_status=$?

	((__nerdline_test_total++))

	if [[ $cmd_status -eq $expected_code ]]; then
		((__nerdline_test_passed++))
		echo -e "${__nerdline_test_clr_pass}✓${__nerdline_test_clr_reset} $description"
		return 0
	else
		((__nerdline_test_failed++))
		echo -e "${__nerdline_test_clr_fail}✗${__nerdline_test_clr_reset} $description"
		echo "  Expected exit code: $expected_code"
		echo "  Actual exit code:  $cmd_status"
		return 1
	fi
}

function nerdline_test_run()
{
	local test_name="$1"
	local test_func="$2"

	echo ""
	echo "=== $test_name ==="
	$test_func
}

function __nerdline_test_summary()
{
	echo ""
	echo "================================"
	echo "Tests: $__nerdline_test_total, Passed: $__nerdline_test_passed, Failed: $__nerdline_test_failed"
	echo "================================"

	if [[ $__nerdline_test_failed -gt 0 ]]; then
		echo -e "${__nerdline_test_clr_fail}FAILED${__nerdline_test_clr_reset}"
		return 1
	else
		echo -e "${__nerdline_test_clr_pass}PASSED${__nerdline_test_clr_reset}"
		return 0
	fi
}