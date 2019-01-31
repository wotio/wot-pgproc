# (C) 2019, InterDigital Communications, Inc. All rights reserved.
# Distributed under commercial license.

# Include optional sub-plugins
ifneq ($(wildcard includes/make/git/*.mk),)
	include includes/make/git/*.mk
endif

tag-src:: before-tag-src
tag-src:: _check-git-src-tag-set
	@echo "===> Tag source in local git"
	@scripts/git_tag $(GIT_SRC_TAG)
	@echo "Done."
tag-src:: after-tag-src
.PHONY: before-tag-src tag-src after-tag-src

publish-src:: before-publish-src
publish-src::
	@echo "===> Publishing source to git"
	@scripts/git_publish
	@echo "Done."
publish-src:: after-publish-src
.PHONY: before-publish-src publish-src after-publish-src

_check-git-src-tag-set:
	@if [ -z "$(GIT_SRC_TAG)" ]; then echo "ERROR: A git tag was not specified, set the variable GIT_SRC_TAG"; exit 1; fi
.PHONY: _check-git-src-tag-set
