# Since I can't get things to work efficiently and properly with generics, I will start with
# hard-coded but configurable dimensions. We can later remove these and include the code
# as often as we want into different modules where the dimensions are configured differently.

import terminal
import puzzle_4x4
import strutils
import times

erase_screen()
set_cursor_pos(0, 0)

##############################################################################

var
  line_index = 0
  config: Config

echo "═" * 80
for line in "test.txt".lines:
  line_index.inc
  if line_index > 10:
    continue
  #echo "Line " & $line_index & ": " & line
  #echo "─" * 80
  read(config, line)
  #init_random(config)
  init_md(config)
  init_id(config)
  echo config.name
  echo ida_star(config)
  echo "═" * 80

