#!/usr/bin/env bash

function cleanup {
	if [[ "${TMP_TEST_MAKE_DIR}" =~ ^/tmp/test-make ]]; then
		rm -r ${TMP_TEST_MAKE_DIR}
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

# Setup Path to mock git
export PATH=${SCRIPTS_DIR}/bin-make-test:${PATH}

# Create temporary directory for tests
TMP_TEST_MAKE_DIR=$(mktemp -d "/tmp/test-make.XXXXXXXX")
if [ -z "${TMP_TEST_MAKE_DIR}" ]; then
	echo "Temporary directory could not be created"
	exit 1
fi

# Install package
echo
output "TEST: Verify package target does install with install args"
CMD="make package PACKAGE_INSTALL_ARGS=package-install-args"
output "CMD: ${CMD}"
RESULTS=$(${CMD})
echo "${RESULTS}" | head -4 && echo "..."
output $([[ "${RESULTS}" == *Installing\ package\ using\ npm\ registry:\ localhost:4873*npm\ install\ package-install-args* ]] && echo "OK" || echo "NOK")

# Publish package
echo
output "TEST: Verify publish-package target does publish with publish args"
CMD="make publish-package PACKAGE_PUBLISH_ARGS=package-publish-args"
output "CMD: ${CMD}"
RESULTS=$(${CMD})
echo "${RESULTS}" | head -4 && echo "..."
output $([[ "${RESULTS}" == *Installing\ package\ using\ npm\ registry:\ localhost:4873*npm\ install*Publishing\ package\ to\ npm\ registry:\ localhost:4873*npm\ publish\ package-publish-args* ]] && echo "OK" || echo "NOK")

# Test package
echo
output "TEST: Verify test target does npm test"
CMD="make test"
output "CMD: ${CMD}"
RESULTS=$(${CMD})
echo "${RESULTS}" | head -4 && echo "..."
output $([[ "${RESULTS}" == *Installing\ package\ using\ npm\ registry:\ localhost:4873*npm\ install*Test\ package\ using\ npm\ registry:\ localhost:4873*npm\ test* ]] && echo "OK" || echo "NOK")

# Clean js and js.map files
echo
output "TEST: Verify package-nodejs clean removes all artifacts"
output "Creating ${SCRIPTS_DIR}/../../npm-debug.log file"
echo 1 > ${SCRIPTS_DIR}/../../npm-debug.log
output "Creating directory ${SCRIPTS_DIR}/../../node_modules"
mkdir -p ${SCRIPTS_DIR}/../../node_modules
CMD="make clean-package-nodejs"
output "CMD: ${CMD}"
RESULTS=$(${CMD})
echo "${RESULTS}" | head -4 && echo "..."
output $([[ "${RESULTS}" == ** ]] && echo "OK" || echo "NOK")
echo
output "TEST: ${SCRIPTS_DIR}/../../npm-debug.log is removed"
if [ -f "${SCRIPTS_DIR}/../../npm-debug.log" ]; then
	output "NOK"
else
	output "OK"
fi
output "TEST: ${SCRIPTS_DIR}/../../node_modules is removed"
if [ -d "${SCRIPTS_DIR}/../../node_modules" ]; then
	output "NOK"
else
	output "OK"
fi

output "FINISHED..."
