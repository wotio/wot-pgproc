# (C) 2019, InterDigital Communications, Inc. All rights reserved.
# Distributed under commercial license.

all: help
.PHONY: all

# Catch all to display usage file
# Flag HELP_SEEN is required to output help only once if multiple targets are supplied to make
%:
	@if [ -z "$(HELP_SEEN)" ]; then scripts/help "$(MAKECMDGOALS)"; fi
	$(eval HELP_SEEN = yes)

## Include all functional plugin makefiles
include includes/make/*.mk

## Clean targets
clean:: before-clean
clean::
	@echo "===> Clean build..."
	@rm -fr $(BUILD_DIR)
	@echo "Done."
clean:: after-clean
.PHONY: before-clean clean after-clean
