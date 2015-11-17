type
  Bounds*  = tuple
    md:        int  # Manhattan distance
    ic:        int  # inversion count; divide by rows to get lower bound on moves
  Config*  = tuple
    blank_row: Row
    blank_col: Col
    blank_index: Index
    tiles:     array[0 .. +last_index, Tile]
    h_bounds:  Bounds
    v_bounds:  Bounds

proc `$`(bounds: Bounds): string {.noSideEffect.} =
  result = "md:" & strutils.align($bounds.md, 3) & "; ic:" & strutils.align($bounds.ic, 3)

proc `$`(config: Config): string {.noSideEffect.} =
  result = "┌" & ("──┬" * (cols - 1)) & "──┐\n"
  var index = Index(0)
  for row in all_rows():
    result.add("│")
    for col in all_cols():
      result.add($(config.tiles[int(index)]))
      result.add("│")
      index.inc
    if row == Row(0):
      result.add(" horiz. ")
      result.add($config.h_bounds)
    elif row == Row(1):
      result.add(" vert.  ")
      result.add($config.v_bounds)
    if row < last_row:
      result = result & "\n├" & ("──┼" * (cols - 1)) & "──┤\n"
    else:
      result = result & "\n└" & ("──┴" * (cols - 1)) & "──┘\n"

proc init_md(config: var Config) {.noSideEffect.} =
  config.h_bounds.md = 0
  config.v_bounds.md = 0
  for index in 0 .. +last_index:
    let tile = config.tiles[index]
    if is_blank(tile):
      continue
    config.h_bounds.md.inc abs(+homeCol(tile) - +toCol(Index(index)))
    config.v_bounds.md.inc abs(+homeRow(tile) - +toRow(Index(index)))

proc init_ic(config: var Config) {.noSideEffect.} =
  config.h_bounds.ic = 0
  config.v_bounds.ic = 0
  for i in 0 .. +last_index:
    for j in i+1 .. +last_index:
      if homeIndex(config.tiles[i]) > homeIndex(config.tiles[j]):
        config.v_bounds.ic.inc

proc init_sorted(config: var Config) =
  config.blank_row   = Row(0)
  config.blank_col   = Col(0)
  config.blank_index = Index(0)
  for index in 0 .. +last_index:
    config.tiles[index] = Tile(loc_list[index])

proc random_inclusive(a, b: int): int =
  return a + math.random(b+1-a)

proc init_random(config: var Config, blank_in_home_position = false) =
  init_sorted(config)
  for i in countdown(+last_index, 1):
    let j = random_inclusive(1, i)
    if i != j:
      swap(config.tiles[i], config.tiles[j])
  config.blank_row   = Row(0)
  config.blank_col   = Col(0)
  config.blank_index = Index(0)
  init_ic(config)
  if config.v_bounds.ic mod 2 == 1:
    swap(config.tiles[1], config.tiles[2])
  if not blank_in_home_position:
    let blank = config.tiles[0]
    let new_blank_index = Index(random_inclusive(0, +last_index))
    var i = Index(0)
    for j in canonical_path(Index(0), new_blank_index):
      config.tiles[int(i)] = config.tiles[int(j)]
      i = j
    config.tiles[int(new_blank_index)] = blank
    config.blank_row   = toRow(new_blank_index)
    config.blank_col   = toCol(new_blank_index)
    config.blank_index = new_blank_index

proc is_solved(config: Config): bool =
  return config.h_bounds.md == 0 and config.v_bounds.md == 0

proc bound_md(config: Config): int =
  return config.h_bounds.md + config.v_bounds.md
