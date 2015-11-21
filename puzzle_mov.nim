type
  Sense = range[-1..1]
  Dir = enum
    up    = -cols
    left  = -1
    none  = 0
    right = 1
    down  = cols

proc can_h_move(config: var Config, h_sense: Sense): bool {.noSideEffect.} =
  return (+config.blank_col + h_sense) in 0 .. +last_col
proc can_v_move(config: var Config, v_sense: Sense): bool {.noSideEffect.} =
  return (+config.blank_row + v_sense) in 0 .. +last_row
proc can_move(config: var Config, h_sense, v_sense: Sense): bool {.noSideEffect.} =
  return can_h_move(config, h_sense) and can_v_move(config, v_sense)

proc h_move(config: var Config, h_sense: Sense) =
  let
    row  = config.blank_row
    col2 = config.blank_col
    col1 = col2 + h_sense
    index2 = config.blank_index
    index1 = index2 + h_sense
    tile = config.tiles[+index1]
    home_col = homeCol(tile)
  # update md
  config.h_bounds.md.inc(abs(+col2 - +home_col) - abs(+col1 - +home_col))
  # update id
  for i in all_strictly_between(to_Coindex(index1), to_Coindex(index2)):
    if tile >. config.tiles[+to_Index(i)]:
      config.h_bounds.ic.inc(h_sense)
    else:
      config.h_bounds.ic.dec(h_sense)
    config.h_bounds.id = (config.h_bounds.ic + cols - 2) div (cols - 1)

  # update configuration
  swap(config.tiles[+index1], config.tiles[+index2])
  config.blank_col   = col1
  config.blank_index = index1

proc v_move(config: var Config, v_sense: Sense) =
  let
    row2 = config.blank_row
    row1 = row2 + v_sense
    col  = config.blank_col
    index2 = config.blank_index
    index1 = index2 + v_sense * cols
    tile = config.tiles[+index1]
    home_row = homeRow(tile)
  # update md
  config.v_bounds.md.inc(abs(+row2 - +home_row) - abs(+row1 - +home_row))
  # update id
  for i in all_strictly_between(index1, index2):
    if tile > config.tiles[+i]:
      config.v_bounds.ic.inc(v_sense)
    else:
      config.v_bounds.ic.dec(v_sense)
    config.v_bounds.id = (config.v_bounds.ic + rows - 2) div (rows - 1)


  # update configuration
  swap(config.tiles[+index1], config.tiles[+index2])
  config.blank_row   = row1
  config.blank_index = index1

