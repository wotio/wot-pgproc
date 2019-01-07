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

# tag git with set tag
echo
output "TEST: verify git tag command is issued"
CMD="make tag-src GIT_SRC_TAG=1.0.0"
output "CMD: ${CMD}"
RESULTS=$(${CMD})
echo "${RESULTS}" | head -4 && echo "..."
output $([[ "${RESULTS}" == *Tag\ source\ in\ local\ git*git\ tag\ -f\ -a\ 1.0.0\ -m\ 1.0.0* ]] && echo "OK" || echo "NOK")

# publish git tag
echo
output "TEST: verify source and tags can be published to git"
CMD="make publish-src"
output "CMD: ${CMD}"
RESULTS=$(${CMD})
echo "${RESULTS}" | head -4 && echo "..."
output $([[ "${RESULTS}" == *Publishing\ source\ to\ git*git\ push*git\ push\ --tags* ]] && echo "OK" || echo "NOK")

output "FINISHED..."
