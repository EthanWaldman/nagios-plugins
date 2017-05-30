#!/bin/bash
#
	DIR_PATH=$1
	WARNING_THRESHOLD=$2
	CRITICAL_THRESHOLD=$3

	DIRSIZE_MB=`du -s -m ${DIR_PATH} | tr '\t' ' ' | cut -d' ' -f1`

	if [ ${DIRSIZE_MB} -gt ${CRITICAL_THRESHOLD} ]
	then
		SEV_LEVEL=2
		SEV_TAG="CRITICAL"
	elif [ ${DIRSIZE_MB} -gt ${WARNING_THRESHOLD} ]
	then
		SEV_LEVEL=1
		SEV_TAG="WARNING"
	else
		SEV_LEVEL=0
		SEV_TAG="OK"
	fi

	printf "%s: Total space consumed under %s = %sMB\n" \
		${SEV_TAG} ${DIR_PATH} ${DIRSIZE_MB}
	exit ${SEV_LEVEL}

