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

proc toLoc(row: Row, col: Col): Loc {.noSideEffect.} =
  var outcome = uint32(row) shl row_shift
  outcome = outcome or (uint32(col) shl col_shift)
  outcome = outcome or (uint32(toIndex(row, col)) shl index_shift)
  outcome = outcome or (uint32(toCoindex(row, col)) shl coindex_shift)
  return Loc(outcome)

proc toTile(row: Row, col: Col): Tile {.noSideEffect.} =
  return Tile(toLoc(row, col))

proc toRow(loc: Loc): Row {.noSideEffect.} =
  return Row((+loc and row_mask) shr row_shift)

proc toCol(loc: Loc): Col {.noSideEffect.} =
  return Col((+loc and col_mask) shr col_shift)

proc homeRow(tile: Tile): Row {.noSideEffect.} =
  return toRow(Loc(tile))

proc homeCol(tile: Tile): Col {.noSideEffect.} =
  return toCol(Loc(tile))

proc toIndex(loc: Loc): Index {.noSideEffect.} =
  return Index((+loc and index_mask) shr index_shift)

proc toCoindex(loc: Loc): Coindex {.noSideEffect.} =
  return Coindex((+loc and coindex_mask) shr coindex_shift)

proc homeIndex(tile: Tile): Index {.noSideEffect.} =
  return toIndex(Loc(tile))

proc is_blank(tile: Tile): bool {.noSideEffect.} =
  return +homeIndex(tile) == 0

proc `$`(loc: Loc): string {.noSideEffect.} =
  var index = int(toIndex(loc))
  if index == 0:
    return "  "
  else:
    return strutils.align($index, 2)

proc `$`(tile: Tile): string {.noSideEffect.} =
  return $(Loc(tile))

var
  loc_list: array[0 .. +last_index, Loc]
proc init() =
  for row in all_rows():
    for col in all_cols():
      var loc = toLoc(row, col)
      loc_list[int(toIndex(loc))] = loc
init()
