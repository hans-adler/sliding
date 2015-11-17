# Since I can't get things to work efficiently and properly with generics, I will start with
# hard-coded but configurable dimensions. We can later remove these and include the code
# as often as we want into different modules where the dimensions are configured differently.

# Configuration
const
  rows = 4
  cols = 4

# The encoding of tiles and locations depends on rows and cols being at most 3 bits.
assert(rows in 2..7)
assert(cols in 2..7)

{.hint[XDeclaredButNotUsed]: off.}
{.deadCodeElim:on.}

import strutils
import math
math.randomize()

include puzzle_rci
include puzzle_loc
include puzzle_cfg
include puzzle_mov

##############################################################################

var
  config: Config

init_random(config)
init_md(config)
init_ic(config)
echo config

const found = -1

proc ida_star_search(g, upper_bound: int, forbidden: set[Dir] = {}): int

proc ida_star(): int =
  var upper_bound = bound_md(config)
  while true:
    echo upper_bound
    let r = ida_star_search(0, upper_bound)
    if r == found:
      return upper_bound
    elif r == high(int):
      return high(int)
    upper_bound = r

# g: cost of reaching current configuration from start configuration
# upper_bound: current upper bound for solutions
# forbidden: directions that we currently want excluded from the next step
# returns found once the result has been found
# returns high(int) if there is no solution below the threshold
# otherwise returns the lowest next upper bound that makes sense in this branch
proc ida_star_search(g, upper_bound: int, forbidden: set[Dir] = {}): int =
  #echo($g & "\t" & $upper_bound)
  #echo config
  let f = g + bound_md(config)
  if f > upper_bound:
    return f
  elif is_solved(config):
    echo g
    return found
  var min = high(int)
  if not (left in forbidden) and config.blank_col > Col(0):
    h_move(config, -1)
    let t = ida_star_search(g + 1, upper_bound, {right})
    h_move(config, +1)
    if t == found:
      return found
    if t < min:
      min = t
  if not (right in forbidden) and config.blank_col < last_col:
    h_move(config, +1)
    let t = ida_star_search(g + 1, upper_bound, {left})
    h_move(config, -1)
    if t == found:
      return found
    if t < min:
      min = t
  if not (up in forbidden) and config.blank_row > Row(0):
    v_move(config, -1)
    let t = ida_star_search(g + 1, upper_bound, {down})
    v_move(config, +1)
    if t == found:
      return found
    if t < min:
      min = t
  if not (down in forbidden) and config.blank_row < last_row:
    v_move(config, +1)
    let t = ida_star_search(g + 1, upper_bound, {up})
    v_move(config, -1)
    if t == found:
      return found
    if t < min:
      min = t
  return min

echo ida_star()

