# (C) 2019, InterDigital Communications, Inc. All rights reserved.
# Distributed under commercial license.

# Package language
PACKAGE_COFFEESCRIPT = true

# Package Name
PACKAGE_NAME ?= $$(node -e 'console.log(require("./package.json").name)')

# Package version number
PACKAGE_VERSION ?= $$(node -e 'console.log(require("./package.json").version)')

# directories containing source code
PACKAGE_DIRLIST :=

# options to pass to npm install
PACKAGE_INSTALL_OPTS ?=
PACKAGE_INSTALL_ARGS = $(PACKAGE_INSTALL_OPTS)

# options to pass to npm publish
PACKAGE_PUBLISH_OPTS ?=
PACKAGE_PUBLISH_ARGS = $(PACKAGE_PUBLISH_OPTS) --ignore-scripts
