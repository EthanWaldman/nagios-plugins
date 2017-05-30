#!/bin/bash
#
	MINUTES_BACK=$1

	ELASTICSEARCH_URL=localhost:9200

	CURRENT_INDEX=`TZ=UTC date +logstash-%Y.%m.%d`
	TMP_QUERY_FILE=/var/tmp/elasticsearch_query.$$

	cat << EOI | sed "s/__MINUTES_BACK__/${MINUTES_BACK}/" > ${TMP_QUERY_FILE}
{"query":{"range":{"@timestamp":{"gte":"now-__MINUTES_BACK__m/m","lt":"now/m"}}}}
EOI
	EVENTS_FOUND=`curl ${ELASTICSEARCH_URL}/${CURRENT_INDEX}/_search \
		-d @${TMP_QUERY_FILE} 2>/dev/null \
		| jq ".hits.total"`
	rm -f ${TMP_QUERY_FILE}

	if [ ${EVENTS_FOUND} -gt 0 ]
	then
		printf "OK: Logged events are found\n"
		exit 0
	else
		printf "WARNING: Logged events have not been found in the last %s minutes\n" ${MINUTES_BACK}
		exit 1
	fi
