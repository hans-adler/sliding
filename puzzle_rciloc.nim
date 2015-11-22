{.hint[XDeclaredButNotUsed]: off.}

type
  Sense = range[-1..1]


# More conversions

proc to_Coindex(index: Index): Coindex =
  return to_Coindex(loc_list[+index])

proc to_Index(coindex: Coindex): Index =
  return Index(to_Coindex(Index(coindex)))

# More on order

proc `<.` (index1, index2: Index): bool =
  return loc_list[+index1] <. loc_list[+index2]
proc `<=.` (index1, index2: Index): bool =
  return loc_list[+index1] <=. loc_list[+index2]
proc `>.` (index1, index2: Index): bool =
  return loc_list[+index1] >. loc_list[+index2]
proc `>=.` (index1, index2: Index): bool =
  return loc_list[+index1] >=. loc_list[+index2]

proc `<.` (coindex1, coindex2: Coindex): bool =
  return loc_list[+coindex1] < loc_list[+coindex2]
proc `<=.` (coindex1, coindex2: Coindex): bool =
  return loc_list[+coindex1] <= loc_list[+coindex2]
proc `>.` (coindex1, coindex2: Coindex): bool =
  return loc_list[+coindex1] > loc_list[+coindex2]
proc `>=.` (coindex1, coindex2: Coindex): bool =
  return loc_list[+coindex1] >= loc_list[+coindex2]

# Iterators

iterator all_strictly_between(one_end, other_end: Index): Index =
  var first, last: Index
  if one_end < other_end:
    first = one_end + 1
    last  = other_end - 1
  else:
    first = other_end + 1
    last  = one_end - 1
  for i in int(first)..int(last):
    yield Index(i)

iterator all_strictly_between(one_end, other_end: Coindex): Coindex =
  var first, last: Coindex
  if one_end < other_end:
    first = one_end + 1
    last  = other_end - 1
  else:
    first = other_end + 1
    last  = one_end - 1
  for i in int(first)..int(last):
    yield Coindex(i)

iterator all_strictly_between(one_end, other_end: Index, increment: Sense): Index =
  var result = +one_end - increment
  while result != +other_end:
    yield Index(result)
    result.dec increment

iterator all_strictly_between(one_end, other_end: Coindex, increment: Sense): Coindex =
  var result = +one_end - increment
  while result != +other_end:
    yield Coindex(result)
    result.dec increment

iterator all_strictly_between1(one_end, other_end: Coindex, increment: Sense): Coindex =
  var result = +one_end - increment
  yield Coindex(result)
  result.dec increment
  yield Coindex(result)
  result.dec increment
  yield Coindex(result)
