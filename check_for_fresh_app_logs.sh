#!/bin/bash
#
	FIELD_NAME=$1
	MINUTES_BACK=$2

	ELASTICSEARCH_URL=localhost:9200

	CURRENT_INDEX=`TZ=UTC date +logstash-%Y.%m.%d`
	TMP_QUERY_FILE=/var/tmp/elasticsearch_query.$$

	cat << EOI | sed "s/__FIELD_NAME__/${FIELD_NAME}/" \
		| sed "s/__MINUTES_BACK__/${MINUTES_BACK}/" > ${TMP_QUERY_FILE}
{"query":{"bool":{"must":[{"exists":{"field":"__FIELD_NAME__"}},{"range":{"@timestamp":{"gte":"now-__MINUTES_BACK__m/m","lt":"now/m"}}}]}}}
EOI
	HIT_COUNT=`curl ${ELASTICSEARCH_URL}/${CURRENT_INDEX}/_search \
		-d @${TMP_QUERY_FILE} 2>/dev/null \
		| jq ".hits.total"`
	rm -f ${TMP_QUERY_FILE}

	if [ ${HIT_COUNT} -gt 0 ]
	then
		printf "OK: %s recent log entries with field named %s found within last %s minutes\n" \
			${HIT_COUNT} ${FIELD_NAME} ${MINUTES_BACK}
		exit 0
	else
		printf "CRITICAL: No recent log entries with field named %s found within last %s minutes\n" \
			${FIELD_NAME} ${MINUTES_BACK}
		exit 2
	fi

