#!/bin/sh

############################################
# this script is version from Version.as to git tag.
############################################

MY_DIR=`dirname ${0}`

#######################
# settings
#######################
AWK=/usr/bin/awk
GREP=/usr/bin/grep
VERSION_FILE=${MY_DIR}/src/com/github/sugamasao/as_logger/Version.as
GIT=/opt/local/bin/git
GIT_REMOTE_NAME=as_logger

#######################
# get version
#######################
VERSION=`${GREP} VERSION ${VERSION_FILE} | ${AWK} -F\" '{print $2}'`

#######################
# exec
#######################
${GIT} tag -a -m "taggin version ${VERSION}" ${VERSION}

if [ $? = "1" ];then
	echo "git error. stop this scrpit..."
	exit 1;
fi

${GIT} push ${GIT_REMOTE_NAME} tag ${VERSION}

