# Since I can't get things to work efficiently and properly with generics, I will start with
# hard-coded but configurable dimensions. We can later remove these and include the code
# as often as we want into different modules where the dimensions are configured differently.

# Configuration
const
  rows = 4
  cols = 4

# The encoding of tiles and locations depends on rows and cols being at most 3 bits.
# The solvability criterion depends on them being at least 2.
assert(rows in 2..7)
assert(cols in 2..7)

{.hint[XDeclaredButNotUsed]: off.}
{.deadCodeElim:on.}

import strutils
import math
import terminal
import parseutils
import times
erase_screen()
set_cursor_pos(0, 0)

math.randomize()

include puzzle_rci
include puzzle_loc
include puzzle_cfg
include puzzle_mov

##############################################################################

const found = -1
var
  config: Config
  nodes = 0

proc ida_star_search(g, upper_bound: int, forbidden: set[Dir] = {}): int

proc ida_star(): int =
  var upper_bound = config.bound
  while true:
    echo " " & $upper_bound
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
  nodes.inc
  let f = g + config.bound
  if f > upper_bound:
    return f
  elif is_solved(config):
    echo "Found it after $# steps. Minimum solution is of length $#." % [$nodes, $g]
    #echo config
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

var line_index = 0

for line in "test.txt".lines:
  echo "Line " & $line_index & ": " & line
  if line_index == 0:
    read(config, line)
    #init_random(config)
    init_md(config)
    init_id(config)
    echo config
    let start_time = get_time()
    discard ida_star()
    let finish_time = get_time()
    echo "Spent $# s." % [$(finish_time - start_time)]
    break
  line_index.inc

#echo config
