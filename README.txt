Currently the main file, puzzle.nim, reads in all the others by include.
Compile it with "nim c -d:release -x:off puzzle" for reasonable performance. Without the options you get a debug build with all checks enabled, which is much slower.
