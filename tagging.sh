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
GIT=/opt/local/bin/git
GIT_REMOTE_NAME=as_logger
VERSION_FILE=${MY_DIR}/src/com/github/sugamasao/as_logger/Version.as

#######################
# check version file.
#######################
if [ -f ${VERSION_FILE} ]; then
	echo "fetch version file.[${VERSION_FILE}]";
else
	echo "not found version file.[${VERSION_FILE}]";
fi;

#######################
# get version
#######################
VERSION=`${GREP} VERSION ${VERSION_FILE} | ${AWK} -F\" '{print $2}'`

#######################
# chekc
#######################
INPUT_MESSAGE="local name ${GIT_REMOTE_NAME} tagging version [${VERSION}] ok?[Y/n]"

# OK Cancel のアレ
while [ "${READ_KEY}" != "Y" ] && [ "${READ_KEY}" != "n" ]; do
echo -n "${INPUT_MESSAGE} "
	read READ_KEY;
done;

# n だったら終了するよ
if [ "${READ_KEY}" = "n" ]; then
	exit 1;
fi

#######################
# exec
#######################
${GIT} tag -a -m "taggin version ${VERSION}" ${VERSION}

if [ $? = "1" ];then
	echo "git error. stop this scrpit..."
	exit 1;
fi

${GIT} push ${GIT_REMOTE_NAME} tag ${VERSION}

