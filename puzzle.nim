# Since I can't get things to work efficiently and properly with generics, I will start with
# hard-coded but configurable dimensions. We can later remove these and include the code
# as often as we want into different modules where the dimensions are configured differently.

import terminal
import puzzle_4x4
import strutils
import times
import math

#erase_screen()
#set_cursor_pos(0, 0)


##############################################################################

proc nthroot(a: float, n: int): float =
  var n = float(n)
  result = a
  var x = a / n
  while abs(result-x) > 10e-4:
    x = result
    result = (1.0/n) * (((n-1)*x) + (a / pow(x, n-1)))

let digits = ["⁰", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹"]

proc `$^`(a: int): string =
  var x = a
  result = ""
  var factor = 1
  while 10 * factor <= x:
    factor = factor * 10
  while factor > 0:
    result.add(digits[x div factor])
    x = x mod factor
    factor = factor div 10

proc `$:`(x: int): string =
  var s = $x
  var a: int = s.len mod 3
  if a == 0:
    a = 3
  result = s[0 .. a-1]
  s = s[a .. s.high]
  while s.len > 0:
    result = result & "," & s[0 .. 2]
    s = s[3 .. s.high]

proc pad(s: string, len: int): string =
  if len < 0:
    return (" " * (-len - s.len)) & s
  else:
    return s & (" " * (len - s.len))

proc make_line(config: Config, outcome: ref Outcome): string =
  let branching_factor = format_float(nthroot(float(outcome.nodes_visited), outcome.g), ffDecimal, 2)
  let time_per_node = pad(format_float(outcome.time * float(1000000000) / float(outcome.nodes_visited), ffDecimal, 1), -8)
  let nodes = pad($:outcome.nodes_visited, -15)
  return "║$#│ $# ns │ $# = $#$# ║" %
    [pad(config.name, 12), time_per_node, nodes, branching_factor, $^outcome.g]

var
  line_index = 0
  config: Config

const
  number_of_lines = 15

proc make_line(left, middle, right, sep: string): string =
  return left & (middle * 12) & sep & (middle * 13) & sep & (middle * 26) & right

echo make_line("╔", "═", "╗", "╤")
echo "║ Name       │ Time / node │ Nodes visited            ║"
echo make_line("╠", "═", "╣", "╪")
for line in "test.txt".lines:
  line_index.inc
  if line_index > number_of_lines:
    continue
  #echo "Line " & $line_index & ": " & line
  #echo "─" * 79
  read(config, line)
  #init_random(config)
  init_md(config)
  init_id(config)
  echo make_line(config, ida_star(config))
  if (line_index mod 5 == 0) and line_index != number_of_lines:
    if line_index mod 10 == 0:
      echo make_line("╟", "─", "╢", "┼")
    else:
      echo make_line("╟", "╌", "╢", "┼")
echo make_line("╚", "═", "╝", "╧")

