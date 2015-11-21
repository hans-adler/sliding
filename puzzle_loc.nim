type
  Loc*          = distinct uint32
  Tile*         = distinct Loc

const
  row_shift     = 0'u32
  row_mask      = 7'u32 shl row_shift
  col_shift     = 3'u32
  col_mask      = 7'u32 shl col_shift
  index_shift   = 6'u32
  index_mask    = 63'u32 shl index_shift
  coindex_shift = 12'u32
  coindex_mask  = 63'u32 shl coindex_shift

template glorified_unsigned(typ: typedesc): stmt =
  proc `+`(x: typ): uint32 = return uint32(x)

glorified_unsigned(Loc)
glorified_unsigned(Tile)

# Conversion between types

proc to_Loc(row: Row, col: Col): Loc {.noSideEffect.} =
  var outcome = uint32(row) shl row_shift
  outcome = outcome or (uint32(col) shl col_shift)
  outcome = outcome or (uint32(to_Index(row, col)) shl index_shift)
  outcome = outcome or (uint32(to_Coindex(row, col)) shl coindex_shift)
  return Loc(outcome)

proc to_Tile(row: Row, col: Col): Tile {.noSideEffect.} =
  return Tile(to_Loc(row, col))

proc to_Row(loc: Loc): Row {.noSideEffect.} =
  return Row((+loc and row_mask) shr row_shift)

proc to_Col(loc: Loc): Col {.noSideEffect.} =
  return Col((+loc and col_mask) shr col_shift)

proc home_Row(tile: Tile): Row {.noSideEffect.} =
  return to_Row(Loc(tile))

proc home_Col(tile: Tile): Col {.noSideEffect.} =

  return to_Col(Loc(tile))

proc to_Index(loc: Loc): Index {.noSideEffect.} =
  return Index((+loc and index_mask) shr index_shift)

proc to_Coindex(loc: Loc): Coindex {.noSideEffect.} =
  return Coindex((+loc and coindex_mask) shr coindex_shift)

proc home_Index(tile: Tile): Index {.noSideEffect.} =
  return to_Index(Loc(tile))

proc home_Coindex(tile: Tile): Coindex {.noSideEffect.} =
  return to_Coindex(Loc(tile))


# Order

proc `<` (loc1, loc2: Loc): bool {.noSideEffect.} =
  return to_Index(loc1) <  to_Index(loc2)
proc `<=`(loc1, loc2: Loc): bool {.noSideEffect.} =
  return to_Index(loc1) <= to_Index(loc2)
proc `>` (loc1, loc2: Loc): bool {.noSideEffect.} =
  return to_Index(loc1) >  to_Index(loc2)
proc `>=`(loc1, loc2: Loc): bool {.noSideEffect.} =
  return to_Index(loc1) >= to_Index(loc2)

proc `<` (tile1, tile2: Tile): bool {.noSideEffect.} =
  return home_Index(tile1) <  home_Index(tile2)
proc `<=`(tile1, tile2: Tile): bool {.noSideEffect.} =
  return home_Index(tile1) <= home_Index(tile2)
proc `>` (tile1, tile2: Tile): bool {.noSideEffect.} =
  return home_Index(tile1) >  home_Index(tile2)
proc `>=`(tile1, tile2: Tile): bool {.noSideEffect.} =
  return home_Index(tile1) >= home_Index(tile2)

proc `<.` (loc1, loc2: Loc): bool {.noSideEffect.} =
  return to_Coindex(loc1) <  to_Coindex(loc2)
proc `<=.`(loc1, loc2: Loc): bool {.noSideEffect.} =
  return to_Coindex(loc1) <= to_Coindex(loc2)
proc `>.` (loc1, loc2: Loc): bool {.noSideEffect.} =
  return to_Coindex(loc1) >  to_Coindex(loc2)
proc `>=.`(loc1, loc2: Loc): bool {.noSideEffect.} =
  return to_Coindex(loc1) >= to_Coindex(loc2)

proc `<.` (tile1, tile2: Tile): bool {.noSideEffect.} =
  return home_Coindex(tile1) <  home_Coindex(tile2)
proc `<=.`(tile1, tile2: Tile): bool {.noSideEffect.} =
  return home_Coindex(tile1) <= home_Coindex(tile2)
proc `>.` (tile1, tile2: Tile): bool {.noSideEffect.} =
  return home_Coindex(tile1) >  home_Coindex(tile2)
proc `>=.`(tile1, tile2: Tile): bool {.noSideEffect.} =
  return home_Coindex(tile1) >= home_Coindex(tile2)


# Recognising empty 'tile'

proc is_empty_tile(tile: Tile): bool {.noSideEffect.} =
  return +home_index(tile) == 0


# Conversion to string

proc `$`(loc: Loc): string {.noSideEffect.} =
  var index = int(to_Index(loc))
  if index == 0:
    return "  "
  else:
    return strutils.align($index, 2)

proc `$`(tile: Tile): string {.noSideEffect.} =
  return $(Loc(tile))

# Sorted array of Locs for quick optimisations

var
  loc_list: array[0 .. +last_index, Loc]
proc init() =
  for row in all_rows():
    for col in all_cols():
      var loc = to_Loc(row, col)
      loc_list[int(to_Index(loc))] = loc
init()
