# This file should be included (not imported) from a module.
# The module needs to set the values of rows and cols to something in range 2..7.
# Example:
#
# const
#   rows = 4
#   cols = 4
#
# include puzzle_generic

# The encoding of tiles and locations depends on rows and cols being at most 3 bits.
# The solvability criterion depends on them being at least 2.
assert(rows in 2..7)
assert(cols in 2..7)

{.deadCodeElim:on.} # applies to entire module


import math
import strutils
import parseutils
import times
math.randomize()

{.hint[XDeclaredButNotUsed]: off.}

include puzzle_rci
include puzzle_loc
include puzzle_rciloc
include puzzle_cfg
include puzzle_mov
include puzzle_ida_star

