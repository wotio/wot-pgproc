# (C) 2018, InterDigital Communications, Inc. All rights reserved.
# Distributed under commercial license.

all: help

# Catch all to display usage file
# Flag HELP_SEEN is required to output help only once if multiple targets are supplied to make
%:
	@if [ -z "$(HELP_SEEN)" ]; then scripts/help "$(MAKECMDGOALS)"; fi
	$(eval HELP_SEEN = yes)

## Include all functional plugin makefiles
include includes/*.mk

## Clean targets
clean:
	@echo "===> Clean build..."
	@rm -fr $(BUILD_DIR)
	@echo "Done."

.PHONY: clean
