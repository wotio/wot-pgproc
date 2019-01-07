# (C) 2018, InterDigital Communications, Inc. All rights reserved.
# Distributed under commercial license.

# Include optional sub-plugins
ifneq ($(wildcard includes/make/package-nodejs/*.mk),)
	include includes/make/package-nodejs/*.mk
endif

package:: before-package
package::
	@echo "===> Installing package using npm registry: $$(npm config get registry)"
	@npm install $(PACKAGE_INSTALL_ARGS)
	@echo "Done."
package:: after-package
.PHONY: before-package package after-package

publish-package:: before-publish-package
publish-package:: package
	@echo "===> Publishing package to npm registry: $$(npm config get registry)"
	@npm publish $(PACKAGE_PUBLISH_ARGS)
	@echo "Done."
publish-package:: after-publish-package
.PHONY: before-publish-package publish-package after-publish-package

## Test targets
test:: before-test
test:: package
	@echo "===> Test package using npm registry: $$(npm config get registry)"
	@npm test
	@echo "Done."
test:: after-test
.PHONY: before-test test after-test

## Clean targets
clean-package-nodejs:: before-clean-package-nodejs
clean-package-nodejs::
	@echo "===> Clean package-nodejs artifacts..."
	@if [ "$(PACKAGE_COFFEESCRIPT)" = "true" ]; then scripts/clean_js $(PACKAGE_DIRLIST); fi
	@rm -f npm-debug.log
	@rm -fr node_modules
	@echo "Done."
clean-package-nodejs:: after-clean-package-nodejs
.PHONY: before-clean-package-nodejs clean-package-nodejs after-clean-package-nodejs
