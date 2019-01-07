#!/usr/bin/env bash

function output {
	COLOR='\033[0;34m'
	if [ "${1}" == "OK" ]; then
		COLOR='\033[0;32m'
	elif [ "${1}" == "NOK" ]; then
		COLOR='\033[0;31m'
	fi

	echo -e "${COLOR}===> ${1}\033[0m"
}

# Current working directory of scripts directory
SCRIPTS_DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

output
output "Running main.sh"
output
${SCRIPTS_DIR}/main.sh

output
output "Running git-hook.sh"
output
${SCRIPTS_DIR}/git-hook.sh

output
output "Running git.sh"
output
${SCRIPTS_DIR}/git.sh

output
output "Running package-nodejs-hook.sh"
output
${SCRIPTS_DIR}/package-nodejs-hook.sh

output
output "Running package-nodejs.sh"
output
${SCRIPTS_DIR}/package-nodejs.sh

output "FINISHED..."
