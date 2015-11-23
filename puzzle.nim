# Since I can't get things to work efficiently and properly with generics, I will start with
# hard-coded but configurable dimensions. We can later remove these and include the code
# as often as we want into different modules where the dimensions are configured differently.

#import terminal
import puzzle_4x4
import strutils
import times
import math

const
  number_of_puzzles = 50
  random_puzzles = false
  seed = 2

math.randomize(seed)


#erase_screen()
#set_cursor_pos(0, 0)


##############################################################################

proc human_time(time_in_seconds: int): string =
  let seconds = time_in_seconds mod 60
  let time_in_minutes = time_in_seconds div 60
  let minutes = time_in_minutes mod 60
  let time_in_hours = time_in_minutes div 60
  let hours = time_in_hours mod 24
  let days = time_in_hours div 24
  result = ""
  if days > 0:
    result = $days & " days "
  if hours > 0:
    result = $hours & " h "
  if minutes > 0:
    result &= $minutes & " min "
  if (days == 0 and seconds > 0) or (time_in_seconds == 0):
    result &= $seconds & " s "
  result.removeSuffix(' ')

proc nth_root(a: float, n: int): float =
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
  let branching_factor = format_float(nth_root(float(outcome.nodes_visited), outcome.g), ffDecimal, 2)
  let time_per_node = pad(format_float(outcome.time * float(1000000000) / float(outcome.nodes_visited), ffDecimal, 1), -8)
  let nodes = pad($:outcome.nodes_visited, -15)
  return "║$#│ $# ns │ $# = $#$# ║" % [
    pad(config.name, 12),
    time_per_node,
    nodes,
    branching_factor,
    $^outcome.g
    ]

var
  line_index = 0
  config: Config

proc make_line(left, middle, right, sep: string): string =
  return left & (middle * 12) & sep & (middle * 13) & sep & (middle * 26) & right

echo make_line("╔", "═", "╗", "╤")
echo "║ Name       │ Time / node │ Nodes visited            ║"
echo make_line("╠", "═", "╣", "╪")
var
  total_time   = 0.0
  total_nodes  = 0
  depth_counts: array[0..80, int]
for i in depth_counts.low..depth_counts.high:
  depth_counts[i] = 0

proc solve() =
  init_md(config)
  init_id(config)
  let outcome = ida_star(config)
  echo make_line(config, outcome)
  total_time  += outcome.time
  total_nodes += outcome.nodes_visited
  depth_counts[outcome.g].inc
  if (line_index mod 5 == 0) and line_index != number_of_puzzles:
    if line_index mod 10 == 0:
      echo make_line("╟", "─", "╢", "┼")
    else:
      echo make_line("╟", "╌", "╢", "┼")

when random_puzzles:
  while line_index < number_of_puzzles:
    line_index.inc
    var name = $line_index
    while name.len < 4:
      name.insert "0"
    name.insert "rnd$#-" % $seed
    init_random(config, name)
    solve()
else:
  for input_line in "test.txt".lines:
    line_index.inc
    if line_index > number_of_puzzles:
      continue
    read(config, input_line)
    solve()
echo make_line("╠", "═", "╣", "╪")
let time_per_node = pad(format_float(total_time * float(1000000000) / float(total_nodes), ffDecimal, 1), -8)
let nodes = pad($:total_nodes, -15)
echo "║$#│ $# ns │ $#          ║" % [
    pad("Total", 12),
    time_per_node,
    nodes
    ]
echo make_line("╚", "═", "╝", "╧")
echo "Total time: $# ($# s)." % [ human_time(int(total_time)), $int(total_time) ]
echo ""
echo "╔═════╦═════╤═════╤═════╤═════╤═════╤═════╤═════╤═════╤═════╤═════╦═════╗"
echo "║Depth║     ┆     ┆     ┆     ┆     │     ┆     ┆     ┆     ┆     ║Total║"
echo "╠═════╬═════╪═════╪═════╪═════╪═════╪═════╪═════╪═════╪═════╪═════╬═════╣"
for level in 1..8:
  let
    max_depth = level * 10
    min_depth = max_depth - 9
  var
    line = "║$#-$#" % [ pad($min_depth, -2), $max_depth]
    line_percentage = 0.0
  for depth in min_depth .. max_depth:
    let percentage = float(depth_counts[depth]) * 100.0 / float(number_of_puzzles)
    let percentage_string = format_float(percentage, ffDecimal, 1)
    if depth == min_depth:
      line.add "║$#%" % pad(pad(percentage_string, -3), 4)
    elif depth == min_depth + 5:
      line.add "│$#%" % pad(pad(percentage_string, -3), 4)
    else:
      line.add "┆$#%" % pad(pad(percentage_string, -3), 4)
    line_percentage += percentage
  let line_percentage_string = format_float(line_percentage, ffDecimal, 1)
  line.add "║$#%║" % pad(pad(line_percentage_string, -3), 4)
  echo line
echo "╚═════╩═════╧═════╧═════╧═════╧═════╧═════╧═════╧═════╧═════╧═════╩═════╝"
