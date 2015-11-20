run: puzzle.nim puzzle_rci.nim puzzle_loc.nim puzzle_cfg.nim puzzle_mov.nim
	nim c -d:release -x:off puzzle
	./puzzle
debug: puzzle.nim puzzle_rci.nim puzzle_loc.nim puzzle_cfg.nim puzzle_mov.nim
	nim c puzzle
	./puzzle
clean:
	rm -rf nimcache
	rm -f puzzle
puzzle: puzzle.nim puzzle_rci.nim puzzle_loc.nim puzzle_cfg.nim puzzle_mov.nim
	nim c puzzle
