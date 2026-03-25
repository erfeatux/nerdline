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
source "$__nerdline_pfx/lib/functions.sh" colors

function test_isColor_valid_hex_full()
{
	nerdline_test_assert "Valid full hex #ffffff" 0 "$(__nerdline_tmp_isColor '#ffffff'; echo $?)"
	nerdline_test_assert "Valid full hex #000000" 0 "$(__nerdline_tmp_isColor '#000000'; echo $?)"
	nerdline_test_assert "Valid full hex #FF0000" 0 "$(__nerdline_tmp_isColor '#FF0000'; echo $?)"
}

function test_isColor_valid_hex_short()
{
	nerdline_test_assert "Valid short hex #fff" 0 "$(__nerdline_tmp_isColor '#fff'; echo $?)"
	nerdline_test_assert "Valid short hex #000" 0 "$(__nerdline_tmp_isColor '#000'; echo $?)"
	nerdline_test_assert "Valid short hex #F00" 0 "$(__nerdline_tmp_isColor '#F00'; echo $?)"
}

function test_isColor_valid_hex_alpha()
{
	nerdline_test_assert "Valid hex with alpha #ffffffff" 0 "$(__nerdline_tmp_isColor '#ffffffff'; echo $?)"
	nerdline_test_assert "Valid hex with alpha #ff000080" 0 "$(__nerdline_tmp_isColor '#ff000080'; echo $?)"
}

function test_isColor_valid_rgb()
{
	nerdline_test_assert "Valid RGB 0:0:0" 0 "$(__nerdline_tmp_isColor '0:0:0'; echo $?)"
	nerdline_test_assert "Valid RGB 255:255:255" 0 "$(__nerdline_tmp_isColor '255:255:255'; echo $?)"
	nerdline_test_assert "Valid RGB 128:128:128" 0 "$(__nerdline_tmp_isColor '128:128:128'; echo $?)"
	nerdline_test_assert "Valid RGB 0:255:0" 0 "$(__nerdline_tmp_isColor '0:255:0'; echo $?)"
}

function test_isColor_valid_rgb_comma()
{
	nerdline_test_assert "Valid RGB comma 255,0,0" 0 "$(__nerdline_tmp_isColor '255,0,0'; echo $?)"
	nerdline_test_assert "Valid RGB comma 0,255,0" 0 "$(__nerdline_tmp_isColor '0,255,0'; echo $?)"
}

function test_isColor_invalid()
{
	nerdline_test_assert "Invalid hex #gggggg" 1 "$(__nerdline_tmp_isColor '#gggggg'; echo $?)"
	nerdline_test_assert "Invalid hex #ffff" 1 "$(__nerdline_tmp_isColor '#ffff'; echo $?)"
	nerdline_test_assert "Invalid RGB 256:0:0" 1 "$(__nerdline_tmp_isColor '256:0:0'; echo $?)"
	nerdline_test_assert "Invalid RGB 0:256:0" 1 "$(__nerdline_tmp_isColor '0:256:0'; echo $?)"
	nerdline_test_assert "Invalid RGB 0:0:256" 1 "$(__nerdline_tmp_isColor '0:0:256'; echo $?)"
	nerdline_test_assert "Invalid string" 1 "$(__nerdline_tmp_isColor 'notacolor'; echo $?)"
	nerdline_test_assert "Invalid empty" 1 "$(__nerdline_tmp_isColor ''; echo $?)"
}

function test_parseColors_hex_full()
{
	local test_color='#ff0000'
	__nerdline_tmp_parseColors 'test_color'
	nerdline_test_assert "Parse full hex #ff0000" "255:0:0" "$test_color"
}

function test_parseColors_hex_short()
{
	local test_color='#f00'
	__nerdline_tmp_parseColors 'test_color'
	nerdline_test_assert "Parse short hex #f00" "255:0:0" "$test_color"
}

function test_parseColors_hex_alpha()
{
	local test_color='#ff000080'
	__nerdline_tmp_parseColors 'test_color'
	nerdline_test_assert "Parse hex with alpha #ff000080" "255:0:0" "$test_color"
}

function test_parseColors_rgb_colon()
{
	local test_color='0:255:0'
	__nerdline_tmp_parseColors 'test_color'
	nerdline_test_assert "Parse RGB 0:255:0" "0:255:0" "$test_color"
}

function test_parseColors_rgb_comma()
{
	local test_color='255,0,0'
	__nerdline_tmp_parseColors 'test_color'
	nerdline_test_assert "Parse RGB comma 255,0,0" "255:0:0" "$test_color"
}

function test_parseColors_invalid()
{
	local test_color='invalid'
	nerdline_test_assert "Parse invalid color returns 1" 1 "$(__nerdline_tmp_parseColors 'test_color'; echo $?)"
}

__nerdline_test_init

nerdline_test_run "Valid Hex Full" test_isColor_valid_hex_full
nerdline_test_run "Valid Hex Short" test_isColor_valid_hex_short
nerdline_test_run "Valid Hex Alpha" test_isColor_valid_hex_alpha
nerdline_test_run "Valid RGB" test_isColor_valid_rgb
nerdline_test_run "Valid RGB Comma" test_isColor_valid_rgb_comma
nerdline_test_run "Invalid Colors" test_isColor_invalid
nerdline_test_run "Parse Hex Full" test_parseColors_hex_full
nerdline_test_run "Parse Hex Short" test_parseColors_hex_short
nerdline_test_run "Parse Hex Alpha" test_parseColors_hex_alpha
nerdline_test_run "Parse RGB Colon" test_parseColors_rgb_colon
nerdline_test_run "Parse RGB Comma" test_parseColors_rgb_comma
nerdline_test_run "Parse Invalid" test_parseColors_invalid

__nerdline_test_summary