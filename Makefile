prefix      ?= /usr/local
exec_prefix ?= $(prefix)
bindir      ?= $(exec_prefix)/bin
datarootdir ?= $(prefix)/share
mandir      ?= $(datarootdir)/man
man1dir     ?= $(mandir)/man1
man5dir     ?= $(mandir)/man5

VERSION := $(file < VERSION)

# Default target - build files we need in the package, but not pages for the website
.PHONY: all
all: bin completion man

# Build the application itself
.PHONY: bin
bin: temp/dist/bin

temp/dist/bin: src/bin bin/build VERSION
	bin/build "$(VERSION)"

# Build the bash-completion script
.PHONY: completion
completion: temp/dist/bin.bash-completion

temp/dist/bin.bash-completion: temp/dist/bin
	"$<" --completion > "$@"

# Build the man pages
.PHONY: man
man: $(patsubst src/%.md,temp/dist/%.gz,$(wildcard src/*.md))

temp/dist/%.gz: src/%.md bin/generate/man VERSION
	bin/generate/man "$*" "$(VERSION)"

# Build the HTML version of the man pages
.PHONY: pages
pages: $(patsubst src/%.md,temp/pages/%.html,$(wildcard src/*.md)) temp/pages/pandoc.css

temp/pages/%.html: src/%.md bin/generate/page VERSION
	bin/generate/page "$*" "$(VERSION)"

temp/pages/pandoc.css: src/pandoc.css
	cp "$<" "$@"

# Install the files that were previously built
.PHONY: install
install:
	install -Dm 0755 temp/dist/bin "$(DESTDIR)$(bindir)/bin"
	install -Dm 0644 temp/dist/bin.bash-completion "$(DESTDIR)$(datarootdir)/bash-completion/completions/bin"
	install -Dm 0644 temp/dist/bin.1.gz "$(DESTDIR)$(man1dir)/bin.1.gz"
	install -Dm 0644 temp/dist/binconfig.5.gz "$(DESTDIR)$(man5dir)/binconfig.5.gz"

# Clean up all generated files
.PHONY: clean
clean:
# Delete node_modules/ as well to ensure it isn't included in the package source (debuild -sa)
# Ideally I would delete/ignore the .idea/ directory as well, but I need that
# It doesn't matter too much though since the production build happen in CI/CD
	rm -rf temp node_modules
