import strutils

# computed from configured parameters
const
  indices = rows * cols
  
type
  Row*     = distinct range[0..rows - 1]
  Col*     = distinct range[0..cols - 1]
  Index*   = distinct range[0..indices - 1]
  Coindex* = distinct range[0..indices - 1]

const
  last_row   = Row(rows-1)
  last_col   = Col(cols-1)
  last_index = Index(indices-1)

template glorified_number(typ: typedesc): stmt =
  proc `<`*   (x, y: typ): bool {.borrow.}
  proc `<=`*  (x, y: typ): bool {.borrow.}
  proc `==`*  (x, y: typ): bool {.borrow.}
  proc `inc`* (x: var typ, y = 1) {.magic: "Inc", noSideEffect.}
  proc `dec`* (x: var typ, y = 1) {.magic: "Dec", noSideEffect.}
  proc `+`    (x: typ): int {.noSideEffect.} = return int(x)
  proc `+`    (x: typ, y: int): typ {.borrow.}

glorified_number(Row)
glorified_number(Col)
glorified_number(Index)
glorified_number(Coindex)

proc toIndex(row: Row, col: Col): Index {.noSideEffect.} =
  return Index(+row * cols + +col)

proc toRow(index: Index): Row {.noSideEffect.} =
  return Row(+index div cols)

proc toCol(index: Index): Col {.noSideEffect.} =
  return Col(+index mod cols)

proc toCoindex(row: Row, col: Col): Coindex {.noSideEffect.} = 
  return Coindex(+col * rows + +row)

iterator all_rows(): Row {.noSideEffect.} =
  for row in 0 .. +last_row:
    yield Row(row)    

iterator all_cols(): Col {.noSideEffect.} =
  for col in 0 .. +last_col:
    yield Col(col)

# Goes from start to goal, first vertically, then horizontally.
# Excludes start, but includes goal if it is not equal to start.
iterator canonical_path(start, goal: Index): Index {.noSideEffect.} =
  let goal_row = toRow(goal)
  var result = start
  while toRow(result) < goal_row:
    result.inc cols
    yield result
  while toRow(result) > goal_row:
    result.dec cols
    yield result
  if result == goal:
    yield result
  else:
    while result < goal:
      result.inc
      yield result
    while result > goal:
      result.dec
      yield result

proc `$`(row: Row): string {.noSideEffect.} =
  return $(int(row))

proc `$`(col: Col): string {.noSideEffect.} =
  return $(int(col))

proc `$`(index: Index): string {.noSideEffect.} =
  return "(" & $(toRow(index)) & "," & $(toCol(index)) & ")"

proc `*`(s: string, count: int): string {.noSideEffect.} =
  result = ""
  for i in 1..count:
    result.add(s)
