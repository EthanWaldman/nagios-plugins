#!/bin/bash
#
	LOCATION=$1
	MINUTES_BACK=$2
	WARNING_THRESHOLD=$3
	CRITICAL_THRESHOLD=$4

	ELASTICSEARCH_URL=localhost:9200

	CURRENT_INDEX=`TZ=UTC date +logstash-%Y.%m.%d`
	TMP_QUERY_FILE=/var/tmp/elasticsearch_query.$$

	cat << EOI | sed "s/__LOCATION__/${LOCATION}/" \
		| sed "s/__MINUTES_BACK__/${MINUTES_BACK}/" > ${TMP_QUERY_FILE}
{"size":0,"aggs":{"average_response_time":{"avg":{"field":"response_time_ms"}}},"query":{"bool":{"must":[{"match":{"weather_location.keyword":"__LOCATION__"}},{"range":{"@timestamp":{"gte":"now-__MINUTES_BACK__m/m","lt":"now/m"}}}]}}}
EOI
	AVG_RESPONSE_TIME=`curl ${ELASTICSEARCH_URL}/${CURRENT_INDEX}/_search \
		-d @${TMP_QUERY_FILE} 2>/dev/null \
		| jq ".aggregations.average_response_time.value"`
	rm -f ${TMP_QUERY_FILE}

	AVG_RESPONSE_TIME_INT=`echo ${AVG_RESPONSE_TIME} | cut -d'.' -f1`
	if [ ${AVG_RESPONSE_TIME_INT} -gt ${CRITICAL_THRESHOLD} ]
	then
		SEV_LEVEL=2
		SEV_TAG="CRITICAL"
	elif [ ${AVG_RESPONSE_TIME_INT} -gt ${WARNING_THRESHOLD} ]
	then
		SEV_LEVEL=1
		SEV_TAG="WARNING"
	else
		SEV_LEVEL=0
		SEV_TAG="OK"
	fi

	printf "%s: Average response time for location %s over past %s minutes = %s\n" \
		${SEV_TAG} ${LOCATION} ${MINUTES_BACK} ${AVG_RESPONSE_TIME}
	exit ${SEV_LEVEL}

