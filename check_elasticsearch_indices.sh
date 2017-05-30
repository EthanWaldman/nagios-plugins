#!/bin/bash
#
	TMP_INDICES_STATUS=/var/tmp/check_elasticsearch_indices.$$
	curl localhost:9200/_cat/indices 2>/dev/null > ${TMP_INDICES_STATUS}

	if [ -s ${TMP_INDICES_STATUS} ]
	then
		cat ${TMP_INDICES_STATUS} | grep -q red
		if [ $? -eq 0 ]
		then
			printf "CRITICAL: Elasticsearch indices in red status found\n"
			cat ${TMP_INDICES_STATUS} | grep red
			SEV_LEVEL=2
		else
			printf "OK: Elasticsearch indices are healthy\n"
			SEV_LEVEL=0
		fi
	else
		printf "CRITICAL: No elasticsearch indices returned!\n"
		SEV_LEVEL=2
	fi

	if [ -f ${TMP_INDICES_STATUS} ]
	then
		rm -f ${TMP_INDICES_STATUS}
	fi

	exit ${SEV_LEVEL}

