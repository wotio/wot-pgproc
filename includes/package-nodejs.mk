# (C) 2018, InterDigital Communications, Inc. All rights reserved.
# Distributed under commercial license.

# Include optional sub-plugins
ifneq ($(wildcard includes/package-nodejs/*.mk),)
	include includes/package-nodejs/*.mk
endif

package:
	@echo "===> Installing package using npm registry: $$(npm config get registry)"
	@npm install $(PACKAGE_INSTALL_ARGS)
	@echo "Done."

publish-package: package
	@echo "===> Publishing package to npm registry: $$(npm config get registry)"
	@npm publish $(PACKAGE_PUBLISH_ARGS)
	@echo "Done."

tag-src:
	@echo "===> Tag package source in local git"
	@scripts/git_tag $(PACKAGE_VERSION)
	@echo "Done."

publish-src:
	@echo "===> Publishing package source to git"
	@scripts/git_publish
	@echo "Done."

## Test targets
test: package
	@echo "===> Test package using npm registry: $$(npm config get registry)"
	@npm test
	@echo "Done."

## Clean targets
clean-package-nodejs:
	@echo "===> Clean package-nodejs artifacts..."
	@if [ "$(PACKAGE_COFFEESCRIPT)" = "true" ]; then scripts/clean_js $(PACKAGE_DIRLIST); fi
	@rm -f npm-debug.log
	@rm -fr node_modules
	@rm -f package-lock.json
	@echo "Done."

.PHONY: package publish-package publish-src tag-src test clean-package-nodejs
