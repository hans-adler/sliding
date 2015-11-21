# Configuration
const
  rows = 4
  cols = 4

include puzzle_generic

proc bound*(config: Config): int =
  return bound_md_id(config)

