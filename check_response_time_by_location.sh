#!/bin/bash
#
	LOCATION=$1
	WARNING_THRESHOLD=$2
	CRITICAL_THRESHOLD=$3

	ELASTICSEARCH_URL=localhost:9200

	CURRENT_INDEX=`TZ=UTC date +logstash-%Y.%m.%d`
	TMP_QUERY_FILE=/var/tmp/elasticsearch_query.$$

	cat << EOI | sed "s/__LOCATION__/${LOCATION}/" > ${TMP_QUERY_FILE}
{"size":1,"query":{"match":{"weather_location.keyword":"__LOCATION__"}},"_source":["@timestamp","response_time_ms"],"sort":{"@timestamp":{"order":"desc"}}}
EOI
	RESPONSE_TIME=`curl ${ELASTICSEARCH_URL}/${CURRENT_INDEX}/_search \
		-d @${TMP_QUERY_FILE} 2>/dev/null \
		| jq ".hits.hits[]._source.response_time_ms"`
	rm -f ${TMP_QUERY_FILE}

	if [ ${RESPONSE_TIME} -gt ${CRITICAL_THRESHOLD} ]
	then
		SEV_LEVEL=2
		SEV_TAG="CRITICAL"
	elif [ ${RESPONSE_TIME} -gt ${WARNING_THRESHOLD} ]
	then
		SEV_LEVEL=1
		SEV_TAG="WARNING"
	else
		SEV_LEVEL=0
		SEV_TAG="OK"
	fi

	printf "%s: Latest response time for location %s = %s\n" \
		${SEV_TAG} ${LOCATION} ${RESPONSE_TIME}
	exit ${SEV_LEVEL}

