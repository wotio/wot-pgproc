#!/usr/bin/env bash

function cleanup {
	if [[ "${TMP_TEST_MAKE_DIR}" =~ ^/tmp/test-make ]]; then
		rm -r ${TMP_TEST_MAKE_DIR}
	fi
	if [[ -f "${TEST_MAKEFILE_PATH}" ]]; then
		rm ${TEST_MAKEFILE_PATH}
	fi

	echo
	echo -e "\033[0;32m======> $(basename $0) RESULT OK  = ${OK:-0}\033[0m"
	echo -e "\033[0;31m======> $(basename $0) RESULT NOK = ${NOK:-0}\033[0m"
	echo
}
trap cleanup EXIT

function output {
	COLOR='\033[0;34m'
	if [ "${1}" == "OK" ]; then
		let OK++
		COLOR='\033[0;32m'
	elif [ "${1}" == "NOK" ]; then
		let NOK++
		COLOR='\033[0;31m'
	fi

	echo -e "${COLOR}===> ${1}\033[0m"
}

# Current working directory of scripts directory
SCRIPTS_DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
cd ${SCRIPTS_DIR}/../..

# Setup Path to mock docker and git
export PATH=${SCRIPTS_DIR}/bin-hook:${PATH}

# Create temporary directory for tests
TMP_TEST_MAKE_DIR=$(mktemp -d "/tmp/test-make.XXXXXXXX")
if [ -z "${TMP_TEST_MAKE_DIR}" ]; then
	echo "Temporary directory could not be created"
	exit 1
fi

# Test Makefile filename
TEST_MAKEFILE=includes/make/test-make.mk
TEST_MAKEFILE_PATH=${SCRIPTS_DIR}/../../${TEST_MAKEFILE}

# Setup Makefile for before and after
output "Create test makefile ${TEST_MAKEFILE}"
cat << EOF > ${TEST_MAKEFILE_PATH}
before-package::
	@echo "BEFORE-package"
after-package::
	@echo "AFTER-package"
before-publish-package::
	@echo "BEFORE-publish-package"
after-publish-package::
	@echo "AFTER-publish-package"
before-test::
	@echo "BEFORE-test"
after-test::
	@echo "AFTER-test"
before-clean-package-nodejs::
	@echo "BEFORE-clean-package-nodejs"
after-clean-package-nodejs::
	@echo "AFTER-clean-package-nodejs"
EOF
cat ${TEST_MAKEFILE_PATH}

# Validate clean before and after hooks
echo
output "TEST: test before/after package-nodejs hooks"

output "TEST: package"
CMD="make package"
output "CMD: ${CMD}"
RESULTS=$(${CMD})
echo "${RESULTS}" | head -4 && echo "..."
output $([[ "${RESULTS}" == *BEFORE-package*Installing\ package*npm\ install*AFTER-package* ]] && echo "OK" || echo "NOK")

output "TEST: publish-package"
CMD="make publish-package"
output "CMD: ${CMD}"
RESULTS=$(${CMD})
echo "${RESULTS}" | head -4 && echo "..."
output $([[ "${RESULTS}" == *BEFORE-publish-package*BEFORE-package*Installing\ package*npm\ install*AFTER-package*Publishing\ package*npm\ publish*AFTER-publish-package* ]] && echo "OK" || echo "NOK")

output "TEST: test"
CMD="make test"
output "CMD: ${CMD}"
RESULTS=$(${CMD})
echo "${RESULTS}" | head -4 && echo "..."
output $([[ "${RESULTS}" == *BEFORE-test*BEFORE-package*Installing\ package*npm\ install*AFTER-package*Test\ package*AFTER-test* ]] && echo "OK" || echo "NOK")

output "TEST: clean-package-nodejs"
CMD="make clean-package-nodejs"
output "CMD: ${CMD}"
RESULTS=$(${CMD})
echo "${RESULTS}" | head -4 && echo "..."
output $([[ "${RESULTS}" == *BEFORE-clean-package-nodejs*Clean\ package-nodejs*AFTER-clean-package-nodejs* ]] && echo "OK" || echo "NOK")

output "Removing makefile ${TEST_MAKEFILE}"
rm ${TEST_MAKEFILE_PATH} &>/dev/null

output "FINISHED..."
