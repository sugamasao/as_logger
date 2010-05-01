#!/bin/sh

MY_DIR=`dirname ${0}`

#######################
# function.
#######################
check_file () {
	if [ -f ${1} ]; then
		echo "[${0}] fetch file.[${1}]";
	else
		echo "[${0}] not found file.[${1}]";
		exit 1;
	fi;
}

check_dir () {
	if [ -d ${1} ]; then
		echo "[${0}] fetch dir.[${1}]";
	else
		echo "[${0}] not found fir.[${1}]";
		exit 1;
	fi;
}

#######################
# settings
#######################
RASCUT=/opt/local/bin/rascut
FLEX_UNIT_PATH=/opt/flex/flexunit/libs
TEST_RUNNER_PATH=${MY_DIR}/src/TestRunner.mxml
LOG="/Users/sugamasao/Library/Preferences/Macromedia/Flash Player/Logs/flashlog.txt"

#######################
# check parameter
#######################
check_file ${RASCUT}
check_file ${TEST_RUNNER_PATH}
check_dir  ${FLEX_UNIT_PATH}

#######################
# exec autotest(rascut)
#######################
if [ -f "${LOG}" ]; then
	${RASCUT} -s --log="${LOG}" -c -compiler.library-path+=${FLEX_UNIT_PATH} ${TEST_RUNNER_PATH}
else
	${RASCUT} -s -c -compiler.library-path+=${FLEX_UNIT_PATH} ${TEST_RUNNER_PATH}
fi;

