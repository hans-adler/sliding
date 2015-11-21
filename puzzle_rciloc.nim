# More conversions

proc to_Coindex(index: Index): Coindex =
  return to_Coindex(loc_list[+index])

proc to_Index(coindex: Coindex): Index =
  return Index(to_Coindex(Index(coindex)))

# More on order

proc `<.` (index1, index2: Index): bool =
  return to_Coindex(index1) < to_Coindex(index2)
proc `<=.` (index1, index2: Index): bool =
  return to_Coindex(index1) <= to_Coindex(index2)
proc `>.` (index1, index2: Index): bool =
  return to_Coindex(index1) > to_Coindex(index2)
proc `>=.` (index1, index2: Index): bool =
  return to_Coindex(index1) >= to_Coindex(index2)

proc `<.` (coindex1, coindex2: Coindex): bool =
  return to_Index(coindex1) < to_Index(coindex2)
proc `<=.` (coindex1, coindex2: Coindex): bool =
  return to_Index(coindex1) <= to_Index(coindex2)
proc `>.` (coindex1, coindex2: Coindex): bool =
  return to_Index(coindex1) > to_Index(coindex2)
proc `>=.` (coindex1, coindex2: Coindex): bool =
  return to_Index(coindex1) >= to_Index(coindex2)

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


