.PHONY: test docs

PANVIMDOC_DIR := .panvimdoc

test:
	nvim -l ./tests/busted.lua tests

# Generate doc/review.txt from README.md via panvimdoc.sh (needs pandoc >= 3.0).
# Clones panvimdoc into $(PANVIMDOC_DIR) on first run; matches the CI workflow's args.
docs: $(PANVIMDOC_DIR)
	mkdir -p doc
	$(PANVIMDOC_DIR)/panvimdoc.sh \
		--project-name review \
		--input-file README.md \
		--vim-version "Neovim >= 0.10.0"

$(PANVIMDOC_DIR):
	git clone --depth 1 https://github.com/kdheepak/panvimdoc $(PANVIMDOC_DIR)
