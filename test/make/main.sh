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

# Create temporary directory for tests
TMP_TEST_MAKE_DIR=$(mktemp -d "/tmp/test-make.XXXXXXXX")
if [ -z "${TMP_TEST_MAKE_DIR}" ]; then
	echo "Temporary directory could not be created"
	exit 1
fi

# Test Makefile filename
TEST_MAKEFILE=includes/make/test-make.mk
TEST_MAKEFILE_PATH=${SCRIPTS_DIR}/../../${TEST_MAKEFILE}

# Validate all target
echo
CMD="make all"
output "TEST: validate all target outputs help"
output "CMD: ${CMD}"
RESULTS=$(${CMD})
echo "$RESULTS" | head -4 && echo "..."
output $([[ "${RESULTS}" == *MAIN\ HELP* ]] && echo "OK" || echo "NOK")

# Validate help on invalid target
echo
CMD="make invalid-target"
output "TEST: validate HELP is displayed for undefined target"
output "CMD: ${CMD}"
RESULTS=$(${CMD})
echo "$RESULTS" | head -4 && echo "..."
output $([[ "${RESULTS}" == *MAIN\ HELP* ]] && echo "OK" || echo "NOK")

# Validate clean removes BUILD_DIR files
echo
output "TEST: clean removes BUILD_DIR"
BUILD_DIRECTORY="${TMP_TEST_MAKE_DIR}/_build"
output "Create Build directory $BUILD_DIRECTORY"
mkdir -p ${BUILD_DIRECTORY}
output "Add file somefile to ${BUILD_DIRECTORY}"
echo 1 > ${BUILD_DIRECTORY}/somefile
find ${BUILD_DIRECTORY}
CMD="make clean BUILD_DIR=${BUILD_DIRECTORY}"
output "CMD: ${CMD}"
RESULTS=$(${CMD})
echo "${RESULTS}" | head -1 && echo "..."
output $([[ "${RESULTS}" == *Clean\ build* ]] && echo "OK" || echo "NOK")
output "VERIFY: check if $BUILD_DIRECTORY was removed"
ls ${BUILD_DIRECTORY} &>/dev/null
RESULT_CODE=$?
output $([[ "${RESULT_CODE}" -eq 2 ]] && echo "OK" || echo "NOK")

# Validate clean before and after hooks
echo
output "TEST: test before/after clean hooks"
BUILD_DIRECTORY="${TMP_TEST_MAKE_DIR}/_build"
output "Create test makefile ${TEST_MAKEFILE}"
cat << EOF > ${TEST_MAKEFILE_PATH}
before-clean::
	@echo "BEFORE-CLEAN"
after-clean::
	@echo "AFTER-CLEAN"
EOF
cat ${TEST_MAKEFILE_PATH}
output "Create Build directory $BUILD_DIRECTORY"
mkdir -p ${BUILD_DIRECTORY}
CMD="make clean BUILD_DIR=${BUILD_DIRECTORY}"
output "CMD: ${CMD}"
RESULTS=$(${CMD})
echo "${RESULTS}" | head -4 && echo "..."
output $([[ "${RESULTS}" == *BEFORE-CLEAN*Clean\ build*AFTER-CLEAN* ]] && echo "OK" || echo "NOK")
output "Removing makefile ${TEST_MAKEFILE}"
rm ${TEST_MAKEFILE_PATH} &>/dev/null

output "FINISHED..."
