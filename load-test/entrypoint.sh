#!/bin/bash -l

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ITER8="/bin/iter8"

echo "Creating working directory"

WORK_DIR=`mktemp -d -p  "$DIR"`
if [[ ! "$WORK_DIR" || ! -d  "$WORK_DIR" ]]; then
  echo "Cound not create temporary working directory"
  exit 1
fi

# no need to cleanup

echo "Fetch load-test experiment"
$ITER8 hub -e load-test
cd load-test

SETS=""
echo "Modify experiment using inputs"
if [[ ! -z "${INPUT_URL}" ]]; then
  SETS="$SETS --set url=${INPUT_URL}"
fi

if [[ ! -z "${INPUT_NUMQUERIES}" ]]; then
  SETS="$SETS --set numQueries=${INPUT_NUMQUERIES}"
fi
if [[ ! -z "${INPUT_DURATION}" ]]; then
  SETS="$SETS --set duration=${INPUT_DURATION}"
fi
if [[ ! -z "${INPUT_QPS}" ]]; then
  SETS="$SETS --set qps=${INPUT_QPS}"
fi
if [[ ! -z "${INPUT_CONNECTIONS}" ]]; then
  SETS="$SETS --set connections=${INPUT_CONNECTIONS}"
fi

if [[ ! -z "${INPUT_PAYLOADSTR}" ]]; then
  SETS="$SETS --set payloadStr=\"${INPUT_PAYLOADSTR}\""
fi
if [[ ! -z "${INPUT_PAYLOADURL}" ]]; then
  SETS="$SETS --set payloadUrl=\"${INPUT_PAYLOADURL}\""
fi
if [[ ! -z "${INPUT_CONTENTTYPE}" ]]; then
  SETS="$SETS --set contentType=\"${INPUT_CONTENTTYPE}\""
fi

if [[ ! -z "${INPUT_ERROR_RATE}" ]]; then
  SETS="$SETS --set SLOs.error-rate=${INPUT_ERROR_RATE}"
fi
if [[ ! -z "${INPUT_MEAN_LATENCY}" ]]; then
  SETS="$SETS --set SLOs.mean-latency=${INPUT_MEAN_LATENCY}"
fi
if [[ ! -z "${INPUT_P25}" ]]; then
  SETS="$SETS --set SLOs.p25=${INPUT_P25}"
fi
if [[ ! -z "${INPUT_P50}" ]]; then
  SETS="$SETS --set SLOs.p50=${INPUT_P50}"
fi
if [[ ! -z "${INPUT_P75}" ]]; then
  SETS="$SETS --set SLOs.p75=${INPUT_P75}"
fi
if [[ ! -z "${INPUT_P90}" ]]; then
  SETS="$SETS --set SLOs.p90=${INPUT_P90}"
fi
if [[ ! -z "${INPUT_P95}" ]]; then
  SETS="$SETS --set SLOs.p95=${INPUT_P95}"
fi
if [[ ! -z "${INPUT_P97_5}" ]]; then
  SETS="$SETS --set SLOs.p\'97\.5'=${INPUT_P97_5}"
fi
if [[ ! -z "${INPUT_P99}" ]]; then
  SETS="$SETS --set SLOs.p99=${INPUT_P99}"
fi
if [[ ! -z "${INPUT_P99_9}" ]]; then
  SETS="$SETS --set SLOs.p\'99\.9\'=${INPUT_P99_9}"
fi

echo "Create experiment.yaml for inspection"
echo $SETS
$ITER8 run --dry $SETS
cat experiment.yaml

echo "Run Experiment"
LOG_LEVEL=trace $ITER8 run $SETS

echo "Log result"
$ITER8 report

echo "Run completed; verifying completeness"
# return 0 if satisfied; else non-zero
$ITER8 assert -c completed -c noFailure -c slos
