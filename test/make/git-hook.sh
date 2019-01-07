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
		COLOR='\033[0;32m'
		let OK++
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
before-tag-src::
	@echo "BEFORE-tag-src"
after-tag-src::
	@echo "AFTER-tag-src"
before-publish-src::
	@echo "BEFORE-publish-src"
after-publish-src::
	@echo "AFTER-publish-src"
EOF
cat ${TEST_MAKEFILE_PATH}


# Validate clean before and after hooks
echo
output "TEST: test before/after git hooks"

output "TEST: tag-src"
CMD="make tag-src"
output "CMD: ${CMD}"
RESULTS=$(${CMD})
echo "${RESULTS}" | head -114 && echo "..."
output $([[ "${RESULTS}" == *BEFORE-tag-src*Adding\ tag*git\ tag*AFTER-tag-src* ]] && echo "OK" || echo "NOK")

output "TEST: publish-src"
CMD="make publish-src"
output "CMD: ${CMD}"
RESULTS=$(${CMD})
echo "${RESULTS}" | head -114 && echo "..."
output $([[ "${RESULTS}" == *BEFORE-publish-src*git\ push*git\ push\ --tags*AFTER-publish-src* ]] && echo "OK" || echo "NOK")

output "Removing makefile ${TEST_MAKEFILE}"
rm ${TEST_MAKEFILE_PATH} &>/dev/null

output "FINISHED..."
