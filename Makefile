# Name of the filter file, *with* `.lua` file extension.
# If you just created this repo with Quarto, run
#     touch <filter-name>.lua first
FILTER_FILE := $(wildcard *.lua)
# Name of the filter without `.lua` file extension
FILTER_NAME = $(patsubst %.lua,%,$(FILTER_FILE))
# Source folder
#	The filter source is main.lua in SOURCE_DIR
#	
SOURCE_DIR = src
# 	Find source files	
SOURCE_FILES := $(wildcard $(SOURCE_DIR)/*.lua)
SOURCE_MODULES := $(SOURCE_FILES:$(SOURCE_DIR)/%.lua=%)
SOURCE_MODULES := $(SOURCE_MODULES:main=)
SOURCE_MAIN = main

# Pandoc example file
TEST_DIR := example-pandoc
TEST_SRC := $(TEST_DIR)/example.md
TEST_DEFAULTS := $(TEST_DIR)/defaults_test.yaml

# Quarto test dir
QUARTO_DIR := example-quarto
QUARTO_FILES := $(wildcard $(QUARTO_DIR)/*.qmd)

# Docs
# Source and defaults for docs version of Pandoc example output
DOCS_SRC = docs/manual.md
DOCS_DEFAULTS := example-pandoc/defaults_man.yaml

# Allow to use a different pandoc binary, e.g. when testing.
PANDOC ?= pandoc
# Allow to adjust the diff command if necessary
DIFF ?= diff
# Use a POSIX sed with ERE ('v' is specific to GNU sed)
SED := sed $(shell sed v </dev/null >/dev/null 2>&1 && echo " --posix") -E

# Pandoc formats for test outputs
# Use make generate FORMAT=pdf to try PDF, 
# not included in the test as PDF files aren't identical on each run
FORMAT ?= html latex

# Directory containing the Quarto extension
QUARTO_EXT_DIR = _extensions/$(FILTER_NAME)
# The extension's name. Used in the Quarto extension metadata
EXT_NAME = $(FILTER_NAME)
# Current version, i.e., the latest tag. Used to version the quarto
# extension.
VERSION = $(shell git tag --sort=-version:refname --merged | head -n1 | \
						 sed -e 's/^v//' | tr -d "\n")
ifeq "$(VERSION)" ""
VERSION = 0.0.0
endif

# GitHub repository; used to setup the filter.
REPO_PATH = $(shell git remote get-url origin | sed -e 's%.*github\.com[/:]%%')
REPO_NAME = $(shell git remote get-url origin | sed -e 's%.*/%%')
USER_NAME = $(shell git config user.name)

## Show available targets
# Comments preceding "simple" targets (those which do not use macro
# name or starts with underscore or dot) and introduced by two dashes
# are used as their description.
.PHONY: help
help:
	@tabs 22 ; $(SED) -ne \
	'/^## / h ; /^[^_.$$#][^ ]+:/ { G; s/^(.*):.*##(.*)/\1@\2/; P ; h ; }' \
	$(MAKEFILE_LIST) | tr @ '\t' 

#
# Build
# 
# automatically triggered on `test` and `generate`

## Build the filter file. Uses luacc if the source dir contains multiple lua files. 
#
# ifeq is safer than ifdef (easier for the user to make
# the variable empty than to make it undefined).
ifeq ($(SOURCE_MODULES), )
$(FILTER_FILE): $(SOURCE_FILES)
	@if [ -f $(QUARTO_EXT_DIR)/$(FILTER_FILE) ]; then \
		cp $(SOURCE_DIR)/$(SOURCE_MAIN).lua $(QUARTO_EXT_DIR)/$(FILTER_FILE); \
		if [ ! -L $(FILTER_FILE) ]; then \
			if [ -f $(FILTER_FILE) ]; then \
				echo "WARNING: $(FILTER_FILE) is a file but should be a link to $(QUARTO_EXT_DIR)/$(FILTER_FILE)."; \
				echo "Please make sure you edited the source $(SOURCE_DIR)/$(SOURCE_MAIN).lua"; \
				read -p "Remove the file and replace with a link? (y/N) " REPLY; \
				if [[ "$$REPLY" == "y" || "$$REPLY" == "y" ]]; then \
					rm $(FILTER_FILE); \
					ln -s $(QUARTO_EXT_DIR)/$(FILTER_FILE) $(FILTER_FILE); \
				else \
					echo "WARNING: $(FILTER_FILE) not up to date."; \
				fi; \
			else \
				ln -s $(QUARTO_EXT_DIR)/$(FILTER_FILE) $(FILTER_FILE); \
			fi; \
		fi; \
	else \
		cp $(SOURCE_DIR)/$(SOURCE_MAIN).lua $(QUARTO_EXT_DIR)/$(FILTER_FILE); \
	fi
else
$(FILTER_FILE): _check_luacc $(SOURCE_FILES)
	@if [ -f $(QUARTO_EXT_DIR)/$(FILTER_FILE) ]; then \
		luacc -o $(QUARTO_EXT_DIR)/$(FILTER_FILE) -i $(SOURCE_DIR) \
			$(SOURCE_DIR)/$(SOURCE_MAIN) $(SOURCE_MODULES); \
		if [ ! -L $(FILTER_FILE) ]; then \
			if [ -f $(FILTER_FILE) ]; then \
				echo "WARNING: $(FILTER_FILE) is a file but should be a link to $(QUARTO_EXT_DIR)/$(FILTER_FILE)."; \
				echo "Please make sure you edited the source $(SOURCE_DIR)/$(SOURCE_MAIN).lua"; \
				read -p "Remove the file and replace with a link? (y/N) " REPLY; \
				if [[ "$$REPLY" == "y" || "$$REPLY" == "y" ]]; then \
					rm $(FILTER_FILE); \
					ln -s $(QUARTO_EXT_DIR)/$(FILTER_FILE) $(FILTER_FILE); \
				else \
					echo "WARNING: $(FILTER_FILE) not up to date."; \
				fi; \
			else \
				ln -s $(QUARTO_EXT_DIR)/$(FILTER_FILE) $(FILTER_FILE); \
			fi; \
		fi; \
	else \
		luacc -o $(FILTER_FILE) -i $(SOURCE_DIR) \
			$(SOURCE_DIR)/$(SOURCE_MAIN) $(SOURCE_MODULES); \
	fi

.PHONY: check_luacc
_check_luacc: 
	@if ! command -v luacc &> /dev/null ; then \
		echo "LuaCC is needed to build the filter. Available on LuaRocks:"; \
		echo " https://luarocks.org/modules/mihacooper/luacc"; \
		exit; \
	fi

endif
#
# Pandoc Test
#

## Test that running the filter on the sample input yields expected outputs
# The automatic variable `$<` refers to the first dependency
# (i.e., the filter file).
# let `test` be a PHONY target so that it is run each time it's called.
# NB: not piping into DIFF. We need to set a --output values for
# paths relative to output to be computed as with the generate target.
.PHONY: test
test: $(FILTER_FILE) $(TEST_FILES)
	@for ext in $(FORMAT) ; do \
		$(PANDOC) --defaults $(TEST_DEFAULTS) \
			--to $$ext \
			--output $(TEST_DIR)/out.$$ext; \
		$(DIFF) $(TEST_DIR)/expected.$$ext $(TEST_DIR)/out.$$ext; \
		rm $(TEST_DIR)/out.$$ext; \
	done

## Generate the expected output for Pandoc
# This target **must not** be a dependency of the `test` target, as that
# would cause it to be regenerated on each run, making the test
# pointless.
.PHONY: generate
generate: $(FILTER_FILE) $(TEST_FILES)
	@for ext in $(FORMAT) ; do \
		echo Creating $(TEST_DIR)/expected.$$ext;\
		$(PANDOC) --defaults $(TEST_DEFAULTS) \
			--to $$ext \
			--output $(TEST_DIR)/expected.$$ext ;\
	done

## Generate output with quarto
.PHONY: quarto
quarto: $(FILTER_FILE) $(QUARTO_FILES)
	echo $(QUARTO_FILES)
	@for fmt in $(FORMAT) ; do \
		quarto render $(QUARTO_FILES) --to $$fmt; \
	done

#
# Website
#
# Website files are placed in the folder `_site`
# Setup on GitHub:
#	- Build and deployment source: GitHub Actions
#	- No need to configure Jekyll or Static. 
# 	  A `.nojekyll` file is automatically added to `_site`.
# Troubleshooting: you may need to update GitHub Actions versions.

## Generate website files in _site
.PHONY: website
website: _site/index.html _site/$(FILTER_FILE)
	@if [ ! -f _site/.nojekyll ]; then \
		touch _site/.nojekyll; \
	fi

_site/index.html: $(DOCS_SRC) $(TEST_FILES) $(FILTER_FILE) .tools/docs.lua \
		_site/output.html _site/style.css
	@mkdir -p _site
	$(PANDOC) \
	    --standalone \
	    --lua-filter=.tools/docs.lua \
		--lua-filter=$(FILTER_FILE) \
	    --metadata=sample-file:$(TEST_SRC) \
	    --metadata=result-file:_site/output.html \
	    --metadata=code-file:$(FILTER_FILE) \
	    --css=style.css \
	    --toc \
	    --output=$@ $<

_site/style.css:
	@mkdir -p _site
	curl \
	    --output $@ \
	    'https://cdn.jsdelivr.net/gh/kognise/water.css@latest/dist/light.css'

_site/output.html: $(FILTER_FILE) $(TEST_SRC) $(DOCS_DEFAULTS)
	@mkdir -p _site
	$(PANDOC) \
	    --defaults=$(DOCS_DEFAULTS) \
		--to=html \
	    --output=$@

_site/$(FILTER_FILE): $(FILTER_FILE)
	@mkdir -p _site
	(cd _site && ln -sf ../$< $<)

#
# Quarto extension
#

## Creates or updates the quarto extension
.PHONY: quarto-extension
quarto-extension: $(QUARTO_EXT_DIR)/_extension.yml \
		$(QUARTO_EXT_DIR)/$(FILTER_FILE)

$(QUARTO_EXT_DIR):
	mkdir -p $@

# This may change, so re-create the file every time
.PHONY: $(QUARTO_EXT_DIR)/_extension.yml
$(QUARTO_EXT_DIR)/_extension.yml: _extensions/$(FILTER_NAME)
	@printf 'Creating %s\n' $@
	@printf 'name: %s\n' "$(EXT_NAME)" > $@
	@printf 'author: %s\n' "$(USER_NAME)" >> $@
	@printf 'version: %s\n'  "$(VERSION)" >> $@
	@printf 'contributes:\n  filters:\n    - %s\n' $(FILTER_FILE) >> $@

# The filter file must be below the quarto _extensions folder: a
# symlink in the extension would not work due to the way in which
# quarto installs extensions.
$(QUARTO_EXT_DIR)/$(FILTER_FILE): $(FILTER_FILE) $(QUARTO_EXT_DIR)
	if [ ! -L $(FILTER_FILE) ]; then \
	    mv $(FILTER_FILE) $(QUARTO_EXT_DIR)/$(FILTER_FILE) && \
	    ln -s $(QUARTO_EXT_DIR)/$(FILTER_FILE) $(FILTER_FILE); \
	fi

#
# Release
#

## Sets a new release (uses VERSION macro if defined)
## Usage make release VERSION=x.y.z
.PHONY: release
release: quarto-extension generate
	git commit -am "Release $(FILTER_NAME) $(VERSION)"
	git tag v$(VERSION) -m "$(FILTER_NAME) $(VERSION)"
	@echo 'Do not forget to push the tag back to github with `git push --tags`'

#
# Set up (normally used only once)
#

## Update filter name
.PHONY: update-name
update-name:
	sed -i'.bak' -e 's/greetings/$(FILTER_NAME)/g' README.md
	sed -i'.bak' -e 's/greetings/$(FILTER_NAME)/g' test/test.yaml
	rm README.md.bak test/test.yaml.bak

## Set everything up (must be used only once)
.PHONY: setup
setup: update-name
	git mv greetings.lua $(REPO_NAME).lua
	@# Crude method to updates the examples and links; removes the
	@# template instructions from the README.
	sed -i'.bak' \
	    -e 's/greetings/$(REPO_NAME)/g' \
	    -e 's#tarleb/lua-filter-template#$(REPO_PATH)#g' \
      -e '/^\* \*/,/^\* \*/d' \
	    README.md
	sed -i'.bak' -e 's/greetings/$(REPO_NAME)/g' test/test.yaml
	sed -i'.bak' -e 's/Albert Krewinkel/$(USER_NAME)/' LICENSE
	rm README.md.bak test/test.yaml.bak LICENSE.bak

#
# Helpers
#

## Clean regenerable files
.PHONY: clean
clean:
	rm -rf _site/*
	rm -rf $(TEST_DIR)/expected.*
	rm -f $(QUARTO_DIR)/example.html
	rm -f $(QUARTO_DIR)/example.tex
	rm -f $(QUARTO_DIR)/example.pdf
	rm -rf $(QUARTO_DIR)/example_files

