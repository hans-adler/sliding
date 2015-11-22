{.hint[XDeclaredButNotUsed]: off.}

type
  Outcome* = object of Exception
    nodes_visited*: int
    g*:             int
    upper_bound*:   int
    time*:          float
    algorithm*:     string

proc `$`*(outcome: ref Outcome): string =
  let time_passed = format_float(outcome.time, ffDecimal, 3)
  return "Length $# minimal solution found in $# s after visiting $# nodes." % [$outcome.g, time_passed, $outcome.nodes_visited]

proc ida_star_search(config: var Config, outcome: ref Outcome, forbidden: Dir = none)

proc ida_star*(config: Config): ref Outcome =
  let outcome = newException(Outcome, "IDA* finished")
  var c: Config = config
  outcome.nodes_visited = 0
  outcome.upper_bound   = config.bound
  outcome.algorithm     = "IDA*"
  let start_time = epoch_time()
  try:
    while true:
      outcome.g = 0
      ida_star_search(c, outcome)
      outcome.upper_bound.inc 2
  except:
    let finish_time = epoch_time()
    let outcome = (ref Outcome) get_current_exception()
    outcome.time = finish_time - start_time
    return outcome

# g: cost of reaching current configuration from start configuration
# upper_bound: current upper bound for solutions
# forbidden: directions that we currently want excluded from the next step
# returns found once the result has been found
# returns high(int) if there is no solution below the threshold
# otherwise returns the lowest next upper bound that makes sense in this branch
proc ida_star_search(config: var Config, outcome: ref Outcome, forbidden: Dir = none) =
  #echo($outcome.g)
  #echo config
  outcome.nodes_visited.inc
  let f = outcome.g + config.bound
  if f > outcome.upper_bound:
    return
  elif is_solved(config):
    raise outcome
  outcome.g.inc
  if not (left == forbidden) and config.blank_col > Col(0):
    h_move(config, -1)
    ida_star_search(config, outcome, right)
    h_move(config, +1)
  if not (up == forbidden) and config.blank_row > Row(0):
    v_move(config, -1)
    ida_star_search(config, outcome, down)
    v_move(config, +1)
  if not (right == forbidden) and config.blank_col < last_col:
    h_move(config, +1)
    ida_star_search(config, outcome, left)
    h_move(config, -1)
  if not (down == forbidden) and config.blank_row < last_row:
    v_move(config, +1)
    ida_star_search(config, outcome, up)
    v_move(config, -1)
  outcome.g.dec

