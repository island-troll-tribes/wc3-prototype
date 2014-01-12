include .wc3settings


COMPILETIME_SOURCES = $(shell git grep -l @compiletime -- 'src/*.wurst')
SOURCES = $(shell find src -type f -name '*.[j,wurst]')

DIST_FLAGS = -opt -inline
TEST_FLAGS = -opt -stacktraces

TRANSPILER = wurst

CHANGELOG_FILE = CHANGELOG.md

ifeq ($(WC3_WINDOWED), true)
  WC3 += -window
endif


build: FLAGS := $(TEST_FLAGS)
build: $(MAP)

test: FLAGS := $(TEST_FLAGS) -runtests
test: $(MAP)

dist: FLAGS := $(DIST_FLAGS)
dist: $(MAP)

%.w3x: $(SOURCES) compiletime
	$(TRANSPILER) $(FLAGS) $< $@

compiletime: $(COMPILETIME_SOURCES)
	$(TRANSPILER) $(FLAGS) -compiletime $(SOURCES) $(MAP)
	exit

run: build
	$(WC3) -loadfile $(TEST_MAP)

edit:
	$(WC3_WE) -loadfile $(BASE_W3X)

deploy:
	scripts/deploy

protect: dist
	scripts/protect $(MAP)

changelog: $(CHANGELOG_FILE)

$(CHANGELOG_FILE):
	scripts/changelog $@

clean:
	$(RM) -rf logs tmp.j process.out $(CHANGELOG_FILE)

clean_vim: 
	find . \( -name ".*.un~" -o -name ".*.sw*" \) -exec $(RM) -rf {} \;

.PHONY: build dist test compiletime run edit protect deploy changelog clean clean_vim
