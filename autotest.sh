#!/bin/sh

MY_DIR=`dirname ${0}`

#######################
# settings
#######################
LASCUT=/opt/local/bin/rascut
FLEX_UNIT_PATH=/opt/flex/flexunit/libs
TEST_RUNNER_PATH=${MY_DIR}/src/TestRunner.mxml

echo ${LASCUT}

${LASCUT} -s -c -compiler.library-path+=${FLEX_UNIT_PATH} ${TEST_RUNNER_PATH}

